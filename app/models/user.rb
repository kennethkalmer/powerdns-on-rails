require 'digest/sha1'
class User < ActiveRecord::Base
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  
  before_save :encrypt_password
  after_destroy :persist_audits
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :admin

  has_and_belongs_to_many :roles
  has_many :domains, :dependent => :nullify
  has_many :zone_templates, :dependent => :nullify
  has_many :audits, :as => :user
  
  acts_as_state_machine :initial => :active
  state :active, :enter => :do_activate
  state :suspended
  state :deleted, :enter => :do_delete

  event :suspend do
    transitions :from => :active, :to => :suspended
  end
  
  event :unsuspend do
    transitions :from => :suspended, :to => :active
  end
  
  event :delete do
    transitions :from => [:suspended, :active], :to => :deleted
  end
  
  class << self
    
    # Returns a list of active owners for the domain
    def active_owners
      find_in_state(:all, :active).select { |u| u.has_role?('owner') }
    end
    
    # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
    def authenticate(login, password)
      u = find_in_state :first, :active, :conditions => {:login => login} # need to get the salt
      u && u.authenticated?(password) ? u : nil
    end
    
    # Encrypts some data with the salt.
    def encrypt(password, salt)
      Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    end
    
    # For our lookup purposes
    def search( params, page )
      paginate :per_page => 50, :page => page, 
        :conditions => ['login LIKE ?', "%#{params.chomp}%"]
    end
    
    # Users with User role
    def find_owners(page)
      r = Role.find_by_name("owner", :select => :id)
      users = r.users.collect {|u| u.id }.join(',')
      
      users.size == 0 ? nil : 
        paginate( :per_page => 50, :page => page, 
        :conditions => "id IN (#{ users })", :order => 'login' )
    end
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  
  # has_role? simply needs to return true or false whether a user has a role or not.  
  def has_role?(role_in_question)
    @_list ||= self.roles.collect(&:name)
    (@_list.include?(role_in_question.to_s) )
  end
  
  # Returns true if the user has the admin role
  def admin?
    @admin ||= has_role?( 'admin' )
  end
  alias :admin :admin?
  
  # Temporary placeholder for an admin value
  def admin=( value )
    @admin = case value
    when String, Symbol
      value.to_s == "true"
    else
      value
    end
  end
  
  def <=>(user)
    user.login <=> self.login 
  end
  
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.nil? || !password.nil?
    end
    
    def do_delete
      self.deleted_at = Time.now.utc
    end

    def do_activate
      encrypt_password
      @activated = true
      self.activated_at = Time.now.utc
      self.deleted_at = self.activation_code = nil
    end
    
    def persist_audits
      quoted_login = ActiveRecord::Base.connection.quote(self.login)
      Audit.update_all( 
                       "username = #{quoted_login}", 
                       [ 'user_type = ? AND user_id = ?', self.class.class_name, self.id ] 
                       )
    end
end
