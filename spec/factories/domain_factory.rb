FactoryGirl.define do

  factory :domain do
    name 'example.com'
    add_attribute :type, 'NATIVE'
    ttl  86400
    # soa
    primary_ns { "ns1.#{name}" }
    contact { "admin@#{name}" }
    refresh 10800
    self.retry 7200 # retry is a keyword in ruby
    expire 604800
    minimum 10800
  end

  #factory :soa, :class => 'SOA' do
  #  name { |r| r.domain.name }
  #  ttl 86400
  #  #content { |r| "ns1.#{r.domain.name} admin@#{r.domain.name} 2008040101 10800 7200 604800 10800" }
  #  primary_ns { |r| "ns1.#{r.domain.name}" }
  #  contact { |r| "admin@#{r.domain.name}" }
  #  refresh 10700
  #  retry 7200
  #  expire 604800
  #  minimum 10800
  #end

  factory :ns, :class => 'NS' do
    ttl 86400
    name { domain.name }
    content { "ns1.#{domain.name}" }
  end

  factory :ns_a, :class => 'A' do
    ttl  86400
    name { "ns1.#{domain.name}" }
    content "10.0.0.1"
  end

  factory :a, :class => 'A' do
    ttl 86400
    name { domain.name }
    content '10.0.0.3'
  end

  factory :www, :class => 'A' do
    ttl 86400
    name { "www.#{domain.name}" }
    content '10.0.0.3'
  end

  factory :mx, :class => 'MX' do
    ttl 86400
    name { domain.name }
    content { "mail.#{domain.name}" }
    prio 10
  end

  factory :mx_a, :class => 'A' do
    ttl 86400
    name { "mail.#{domain.name}" }
    content '10.0.0.4'
  end

end
