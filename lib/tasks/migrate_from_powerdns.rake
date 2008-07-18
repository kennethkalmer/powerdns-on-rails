# Shamelessly copied and modified from the Redmine source
# http://redmine.rubyforge.org/svn/branches/0.7-stable/lib/tasks/migrate_from_trac.rake

require 'iconv'

namespace :migrate do
  
  desc 'Migrate a PowerDNS database into a clean BIND DLZ database'
  task :powerdns => :environment do
    
    module PowerDnsMigration
      
      ###
      # Config values
      ##
      @@db_adapter = nil
      mattr_accessor :db_adapter
      
      @@db_host = nil
      mattr_accessor :db_host
      
      @@db_name = nil
      mattr_accessor :db_name
      
      @@db_username = nil
      mattr_accessor :db_username
      
      @@db_password = nil
      mattr_accessor :db_password
      
      @@db_port = nil
      mattr_accessor :db_port
      
      ###
      # Models
      ###
      class PdnsDomain < ActiveRecord::Base
        set_table_name :domains
        set_inheritance_column 'something_totally_different'
        
        has_many :records, :class_name => 'PdnsRecord', :foreign_key => 'domain_id'
        
        # http://weblog.jamisbuck.org/2007/4/6/faking-cursors-in-activerecord
        def self.each( limit = 500 )
          rows = find(:all, :conditions => ["id > ?", 0], :limit => limit)
          while rows.any?
            rows.each { |record| yield record }
            rows = find(:all, :conditions => ["id > ?", rows.last.id], :limit => limit)
          end
          self
        end

      end
      
      class PdnsRecord < ActiveRecord::Base
        set_table_name :records
        set_inheritance_column 'something_totally_different'
        
        def ns?
          self[:type] =~ /SOA/
        end
      end
      
      def self.migrate!
        establish_connection
        
        # Quick database test
        PdnsDomain.count
        
        migrated_domains = 0
        migrated_records = 0
        
        PdnsDomain.each do |domain|
          print 'Importing ' + domain.name
          
          # copy the records
          records = domain.records.dup
          
          # get the SOA entry
          soa = records.select { |r| r.ns? }.first
          records.delete_if { |r| r.ns? }
          
          # extract SOA information
          soa_ns, soa_contact, soa_serial, soa_refresh, soa_retry, soa_expire, soa_minimum = soa.content.split(' ')
          
          # add the zone
          zone = Zone.find_or_create_by_name( encode( domain.name ) )
          zone.name = encode(domain.name)
          zone.primary_ns = encode(soa_ns)
          zone.contact = encode(soa_contact)
          zone.serial = soa_serial unless soa_serial == 0 # Don't copy 0 a serial
          zone.refresh = soa_refresh
          zone.retry = soa_retry
          zone.expire = soa_expire
          zone.minimum = soa_minimum
          zone.ttl = soa.ttl
          
          next unless zone.save
          
          migrated_domains += 1
          
          # clear the existing records completely (except the SOA)
          Record.delete_all( "zone_id = #{zone.id} AND type <> 'SOA'")
          
          Record.batch do
            # add the remaining records
            domain.records.each do |pdns_record|
              print '.'
              STDOUT.flush
              
              begin
                # create a correct 'type' of record
                record = zone.send( "#{pdns_record.type.downcase}_records".to_sym ).new
              rescue
                next
              end

              # set the correct host value by cleaning up the PowerDNS name field
              record.host = case
              when pdns_record.name == domain.name
                '@'
              else
                encode( pdns_record.name.gsub( ".#{domain.name}", '' ) )
              end

              # set the data, also stripping out the PowerDNS rubbish
              record.data = encode( pdns_record.content.gsub( ".#{domain.name}", '' ) )

              # Set the TTL if we're dealing with an MX
              record.ttl = pdns_record.ttl if record.is_a?( MX )

              next unless record.save

              migrated_records += 1
            end
          end
          
          print "\n"
        end
        
        puts
        puts "Zones:      #{migrated_domains}/#{PdnsDomain.count}"
        puts "Records:    #{migrated_records}/#{PdnsRecord.count}"
        puts
      end
      
      def self.connection_params
        {
          :adapter => db_adapter,
          :database => db_name,
          :host => db_host,
          :port => db_port,
          :username => db_username,
          :password => db_password
        }
      end
      
      def self.establish_connection
        constants.each do |const|
          klass = const_get(const)
          next unless klass.respond_to? 'establish_connection'
          klass.establish_connection connection_params
        end
      end
      
      def self.encoding(charset)
        @ic = Iconv.new('UTF-8', charset)
      rescue Iconv::InvalidEncoding
        puts "Invalid encoding!"
        return false
      end
      
      def self.encode(text)
        @ic.iconv text
      rescue
        text
      end
    end
    
    puts "WARNING: This will import all the domains and records from a PowerDNS"
    puts "database into the local BIND DLZ database. Existing records will be"
    puts "overwritten in the process without warning."
    print "Are you sure you want to continue? [y/N] "
    break unless STDIN.gets.match(/^y$/i)  
    puts
    
    def prompt(text, options = {}, &block)
      default = options[:default] || ''
      while true
        print "#{text} [#{default}]: "
        value = STDIN.gets.chomp!
        value = default if value.blank?
        break if yield value
      end
    end
    
    prompt("PowerDNS database adapter (mysql only at the moment)", :default => 'mysql') { |adapter| PowerDnsMigration.db_adapter = adapter }
    prompt("PowerDNS database host", :default => 'localhost') { |host| PowerDnsMigration.db_host = host }
    prompt("PowerDNS database port", :default => 3306) { |port| PowerDnsMigration.db_port = port }
    prompt("PowerDNS database name" ) { |name| PowerDnsMigration.db_name = name }
    prompt("PowerDNS database username") { |user| PowerDnsMigration.db_username = user }
    prompt("PowerDNS database password") { |pass| PowerDnsMigration.db_password = pass }
    prompt('PowerDNS database encoding', :default => 'UTF-8') {|encoding| PowerDnsMigration.encoding encoding}
    
    PowerDnsMigration.migrate!
  end
  
end