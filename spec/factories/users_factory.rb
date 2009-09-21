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
  f.roles [ Factory(:admin_role) ]
end

Factory.define(:quentin, :class => User) do |f|
  f.login 'quentin'
  f.email 'quentin@example.com'
  f.password 'test'
  f.password_confirmation 'test'
  f.roles [ Factory(:owner_role) ]
end

Factory.define(:aaron, :class => User) do |f|
  f.login 'aaron'
  f.email 'aaron@example.com'
  f.password 'test'
  f.password_confirmation 'test'
end
