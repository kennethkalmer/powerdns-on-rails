Factory.define :admin_role, :class => Role do |f|
  f.name 'admin'
end

Factory.define :owner_role, :class => Role do |f|
  f.name 'owner'
end

Factory.define :auth_token_role, :class => Role do |f|
  f.name 'auth_token'
end

Factory.define :admin, :class => User do |f|
  f.login 'admin'
  f.email 'admin@example.com'
  f.password 'test'
  f.password_confirmation 'test'
  f.roles [ Role.find_by_name('admin') || Factory(:admin_role) ]
end

Factory.define(:quentin, :class => User) do |f|
  f.login 'quentin'
  f.email 'quentin@example.com'
  f.password 'test'
  f.password_confirmation 'test'
  f.roles [ Role.find_by_name('owner') || Factory(:owner_role) ]
end

Factory.define(:aaron, :class => User) do |f|
  f.login 'aaron'
  f.email 'aaron@example.com'
  f.password 'test'
  f.password_confirmation 'test'
end

Factory.define(:token_user, :class => User) do |f|
  f.login 'token'
  f.email 'token@example.com'
  f.password 'test'
  f.password_confirmation 'test'
  f.roles [ Role.find_by_name('auth_token') || Factory(:auth_token_role) ]
end

Factory.define(:api_client, :class => User) do |f|
  f.login 'api'
  f.email 'api@example.com'
  f.password 'test'
  f.password_confirmation 'test'
  f.roles [ Role.find_by_name('admin_role') || Factory(:admin_role) ]
end
