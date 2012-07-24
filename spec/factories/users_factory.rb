Factory.define :admin, :class => User do |f|
  f.login 'admin'
  f.email 'admin@example.com'
  f.password 'secret'
  f.password_confirmation 'secret'
  f.confirmation_token nil
  f.confirmed_at Time.now
  f.admin true
end

Factory.define(:quentin, :class => User) do |f|
  f.login 'quentin'
  f.email 'quentin@example.com'
  f.password 'secret'
  f.password_confirmation 'secret'
  f.confirmation_token nil
  f.confirmed_at Time.now
end

Factory.define(:aaron, :class => User) do |f|
  f.login 'aaron'
  f.email 'aaron@example.com'
  f.password 'secret'
  f.password_confirmation 'secret'
  f.confirmation_token nil
  f.confirmed_at Time.now
end

Factory.define(:token_user, :class => User) do |f|
  f.login 'token'
  f.email 'token@example.com'
  f.password 'secret'
  f.password_confirmation 'secret'
  f.admin  true
  f.auth_tokens true
  f.confirmation_token nil
  f.confirmed_at Time.now
end

Factory.define(:api_client, :class => User) do |f|
  f.login 'api'
  f.email 'api@example.com'
  f.password 'secret'
  f.password_confirmation 'secret'
  f.admin true
  f.confirmation_token nil
  f.confirmed_at Time.now
end
