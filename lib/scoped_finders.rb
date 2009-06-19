module ScopedFinders

  def self.included( base ) #:nodoc:
    base.extend( ClassMethods )
  end

  module ClassMethods

    def scope_user

      extend SingletonMethods

      class << self
        alias_method_chain :find, :scope
        alias_method_chain :paginate, :scope
      end

    end

  end

  module SingletonMethods
    # Convenient scoped finder method that restricts lookups to the specified
    # :user. If the user has an admin role, the scoping is discarded totally,
    # since an admin _is a admin_.
    #
    # Example:
    #
    #   Domain.find(:all) # Normal behavior
    #   Domain.find(:all, :user => user_instance) # Will scope lookups to the user
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

    # Paginated find with scope. See #find.
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

    # For our lookup purposes
    def search( params, page, user = nil )
      paginate :per_page => 5, :page => page,
        :conditions => ['name LIKE ?', "%#{params.chomp}%"],
        :user => user
    end
  end

end

ActiveRecord::Base.send( :include, ScopedFinders )
