Factory.define(:example_com, :class => 'Domain') do |f|
  f.name 'example.com'
  f.add_attribute :type, 'NATIVE'
  f.ttl  86400
  # soa
  f.primary_ns 'ns1.example.com'
  f.contact 'admin@example.com'
  f.refresh 10800
  f.retry 7200
  f.expire 604800
  f.minimum 10800
end
