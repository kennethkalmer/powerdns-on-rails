Factory.define( :domain, :class => 'Domain' ) do |f|
  f.name 'example.com'
  f.add_attribute :type, 'NATIVE'
  f.ttl  86400
  # soa
  f.primary_ns { |d| "ns1.#{d.name}" }
  f.contact { |d| "admin@#{d.name}" }
  f.refresh 10800
  f.retry 7200
  f.expire 604800
  f.minimum 10800
end

#Factory.define(:soa, :class => 'SOA') do |f|
#  f.name { |r| r.domain.name }
#  f.ttl 86400
#  #f.content { |r| "ns1.#{r.domain.name} admin@#{r.domain.name} 2008040101 10800 7200 604800 10800" }
#  f.primary_ns { |r| "ns1.#{r.domain.name}" }
#  f.contact { |r| "admin@#{r.domain.name}" }
#  f.refresh 10700
#  f.retry 7200
#  f.expire 604800
#  f.minimum 10800
#end

Factory.define(:ns, :class => NS) do |f|
  f.ttl 86400
  f.name { |r| r.domain.name }
  f.content { |r| "ns1.#{r.domain.name}" }
end

Factory.define(:ns_a, :class => A) do |f|
  f.ttl  86400
  f.name { |r| "ns1.#{r.domain.name}" }
  f.content "10.0.0.1"
end

Factory.define(:a, :class => A) do |f|
  f.ttl 86400
  f.name { |r| r.domain.name }
  f.content '10.0.0.3'
end

Factory.define(:www, :class => A) do |f|
  f.ttl 86400
  f.name { |r| "www.#{r.domain.name}" }
  f.content '10.0.0.3'
end

Factory.define(:mx, :class => MX) do |f|
  f.ttl 86400
  f.name { |r| r.domain.name }
  f.content { |r| "mail.#{r.domain.name}" }
  f.prio 10
end

Factory.define(:mx_a, :class => A) do |f|
  f.ttl 86400
  f.name { |r| "mail.#{r.domain.name}" }
  f.content '10.0.0.4'
end
