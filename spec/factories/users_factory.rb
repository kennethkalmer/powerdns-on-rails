FactoryGirl.define do

  factory :admin, :class => User do
    login 'admin'
    email 'admin@example.com'
    password 'secret'
    password_confirmation 'secret'
    confirmation_token nil
    confirmed_at Time.now
    admin true
  end

  factory :quentin, :class => User do
    login 'quentin'
    email 'quentin@example.com'
    password 'secret'
    password_confirmation 'secret'
    confirmation_token nil
    confirmed_at Time.now
  end

  factory :aaron, :class => User do
    login 'aaron'
    email 'aaron@example.com'
    password 'secret'
    password_confirmation 'secret'
    confirmation_token nil
    confirmed_at Time.now
  end

  factory :token_user, :class => User do
    login 'token'
    email 'token@example.com'
    password 'secret'
    password_confirmation 'secret'
    admin  true
    auth_tokens true
    confirmation_token nil
    confirmed_at Time.now
  end

  factory :api_client, :class => User do
    login 'api'
    email 'api@example.com'
    password 'secret'
    password_confirmation 'secret'
    admin true
    confirmation_token nil
    confirmed_at Time.now
  end

end
