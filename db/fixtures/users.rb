# Two Roles
Role.seed( :name ) do |s|
  s.name = 'admin'
end
Role.seed( :name ) do |s|
  s.name = 'owner'
end

# An admin
User.seed( :login ) do |s|
  s.login = 'admin'
  s.email = 'admin@example.com'
  s.password = 'secret'
  s.password_confirmation = 'secret'
  s.state = 'active'
end
User.find_by_login('admin').roles << Role.find_by_name('admin')