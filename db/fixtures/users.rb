# Two Roles
Role.seed( :name ) do |s|
  s.name = 'admin'
end
Role.seed( :name ) do |s|
  s.name = 'owner'
end
Role.seed( :name ) do |s|
  s.name = 'auth_token'
end

# An admin
User.seed( :login ) do |s|
  s.login = 'admin'
  s.email = 'admin@example.com'
  s.password = 'secret'
  s.password_confirmation = 'secret'
end
admin = User.find_by_login('admin')
admin.roles << Role.find_by_name('admin')

# A token user
User.seed( :login ) do |s|
  s.login = 'token'
  s.email = 'tokens@example.com'
  s.password = 'secret'
  s.password_confirmation = 'secret'
end
token = User.find_by_login( 'token' )
token.roles << Role.find_by_name('auth_token')
