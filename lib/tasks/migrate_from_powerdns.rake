# Shamelessly copied and modified from the Redmine source
# http://redmine.rubyforge.org/svn/branches/0.7-stable/lib/tasks/migrate_from_trac.rake

################################################################################
#
# BIG FAT NOISY WARNING
#
# This migration script should be used in a staging environment before running
# it in a production environment!
#
################################################################################

require 'iconv'

namespace :migrate do

  desc 'Migrate an existing PowerDNS database into a clean copy'
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

      @@logger = nil
      @@log_file_path = File.join( RAILS_ROOT, 'log', 'powerdns-import-' + Time.now.strftime("%Y%m%d%H%M%S") + '.log')
      mattr_reader :log_file_path

      ###
      # PowerDNS Models
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

        def soa?
          self[:type] =~ /SOA/
        end
      end

      def self.migrate!
        establish_connection

        # Quick database test
        logger.info "Migration #{PdnsDomain.count.to_s} domains"

        migrated_domains = 0
        migrated_records = 0

        PdnsDomain.each do |domain|
          logger.info "Importing #{domain.name}"
          print "Importing #{domain.name} "

          # copy the records
          pdns_records = domain.records.dup

          # get the SOA entry
          soa = pdns_records.select { |r| r.soa? }.first
          pdns_records.delete_if { |r| r.soa? }

          # check for missing SOA records
          if soa.nil?
            logger.warn "Could not find SOA record for #{domain.name}, skipping domain!"
            print "!\n"
            STDOUT.flush
            next
          end

          # extract SOA information
          soa_ns, soa_contact, soa_serial, soa_refresh, soa_retry, soa_expire, soa_minimum = soa.content.split(' ')

          # remove the zone if it exists
          Domain.destroy_all( [ 'name LIKE ?', domain.name ] )

          # add the zone
          zone = Domain.new
          zone.name = encode(domain.name)
          zone.primary_ns = encode(soa_ns)
          zone.contact = encode(soa_contact)
          zone.serial = soa_serial unless soa_serial == 0 # Don't copy 0 a serial
          zone.refresh = soa_refresh
          zone.retry = soa_retry
          zone.expire = soa_expire
          zone.minimum = (soa_minimum.to_i > 10800 ? 10800 : soa_minimum.to_i)
          zone.ttl = soa.ttl

          # Save and report
          unless zone.save
            logger.warn "* Could not create new Zone/SOA record for #{domain.name}, skipping domain!"
            logger.warn "* ActiveRecord said: #{zone.errors.full_messages.join(', ')}"
            print "!\n"
            STDOUT.flush
            next
          end

          migrated_domains += 1
          migrated_records += 1 # SOA record created above :)

          # clear the existing records completely (except the SOA)
          Record.delete_all( "domain_id = #{zone.id} AND type <> 'SOA'")

          logger.info "* Adding records for #{domain.name}"
          Record.batch do
            # add the remaining records
            pdns_records.each do |pdns_record|
              logger.info "** Importing #{pdns_record.name} #{pdns_record.ttl} IN #{pdns_record.type} #{pdns_record.prio} #{pdns_record.content}"

              begin
                # create a correct 'type' of record
                record = zone.send( "#{pdns_record.type.downcase}_records".to_sym ).new
              rescue
                logger.warn "** #{pdns_record.name} (#{pdns_record.type}) is not supported by this project yet"
                print "!"
                STDOUT.flush
                next
              end

              # copy the name
              record.name = encode( pdns_record.name )
              # copy the content
              record.content = encode( pdns_record.content )

              # ttl
              record.ttl = pdns_record.ttl

              # set the priority if we're dealing with an MX record
              record.prio = pdns_record.prio if record.is_a?( MX )

              # save and report
              unless record.save
                logger.warn "** Could not save record imported from #{pdns_record.name} (#{pdns_record.type})"
                logger.warn "** ActiveRecord said: #{record.errors.full_messages.join(', ')}"
                print '!'
                STDOUT.flush
                next
              end

              migrated_records += 1

              print '.'
              STDOUT.flush
            end
          end

          logger.info ""
          print "\n"
        end

        puts
        puts "Zones:      #{migrated_domains}/#{PdnsDomain.count}"
        puts "Records:    #{migrated_records}/#{PdnsRecord.count}"
        puts
        puts "Verbose logging saved to #{log_file_path}"
        puts
      end

      def self.logger
        @@logger ||= Logger.new( log_file_path )
      end

      def self.connection_params
        {
          :adapter => db_adapter,
          :database => db_name,
          :host => db_host,
          :port => db_port.to_i,
          :username => db_username,
          :password => db_password
        }
      end

      def self.establish_connection
        logger.info "Setting up database connections"
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
    puts "database into the PowerDNS on Rails database. Existing records will be"
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
    prompt('PowerDNS database encoding', :default => 'UTF-8') { |encoding| PowerDnsMigration.encoding encoding }

    puts
    puts "A complete log file containing verbose data will be available at the path below after the migration"
    puts PowerDnsMigration.log_file_path
    puts

    PowerDnsMigration.migrate!
  end

end
