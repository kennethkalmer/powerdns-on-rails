# See #Zone

# = Zone
# 
# A #Zone is a unique domain name entry, and contains various #Record entries to
# represent its data.
# 
# The zone is used for the following purposes:
# * It is the $ORIGIN off all its records
# * It specifies a default $TTL
# * Speedy lookups by bind-dlz to determine if its authorative
# 
class Zone < ActiveRecord::Base
  
  belongs_to :user
  
  has_many :records, :dependent => :destroy
  
  has_one  :soa_record,    :class_name => 'SOA'
  has_many :ns_records,    :class_name => 'NS'
  has_many :mx_records,    :class_name => 'MX'
  has_many :a_records,     :class_name => 'A'
  has_many :txt_records,   :class_name => 'TXT'
  has_many :cname_records, :class_name => 'CNAME'
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  # Virtual attributes that ease new zone creation. If present, they'll be
  # used to create an SOA for the domain
  SOA_FIELDS = [ :primary_ns, :contact, :refresh, :retry, :expire, :minimum ]
  SOA_FIELDS.each do |f|
    attr_accessor f
    validates_presence_of f, :on => :create
  end
  
  class << self
    
    # Convenient scoped finder method that restricts lookups to the specified
    # :user. If the user has an admin role, the scoping is discarded totally,
    # since an admin _is a admin_.
    #
    # Example:
    # 
    #   Zone.find(:all) # Normal behavior
    #   Zone.find(:all, :user => user_instance) # Will scope lookups to the user
    #
    def find_with_scope( *args )
      options = args.extract_options!
      user = options.delete( :user )
      
      unless user.nil? || user.has_role?( 'admin' )
        with_scope( :find => { :conditions => [ 'user_id = ?', user.id ] } ) do
          find_without_scope( *args << options )
        end
      else
        find_without_scope( *args << options )
      end
    end
    alias_method_chain :find, :scope
    
    def paginate_with_scope( *args, &block )
      options = args.pop
      user = options.delete( :user )
      
      unless user.nil? || user.has_role?( 'admin' )
        with_scope( :find => { :conditions => [ 'user_id = ?', user.id ] } ) do
          paginate_without_scope( *args << options, &block )
        end
      else
        paginate_without_scope( *args << options, &block )
      end
    end
    alias_method_chain :paginate, :scope
    
    # For our lookup purposes
    def search( params, page, user = nil )
      paginate :per_page => 5, :page => page, 
        :conditions => ['name LIKE ?', "%#{params}%"],
        :user => user
    end
  end
  
  # return the records, excluding the SOA record
  def records_without_soa
    records.select { |r| !r.is_a?( SOA ) }
  end
  
  # Setup an SOA if we have the requirements
  def after_create #:nodoc:
    soa = SOA.new( :zone => self )
    SOA_FIELDS.each do |f|
      soa.send( "#{f}=", send( f ) )
    end
    soa.save
  end
end
