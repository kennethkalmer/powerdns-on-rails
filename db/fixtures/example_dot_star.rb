# Seed data for PowerDNS on Rails, just to get you started.

# Sample zone
Domain.seed( :name ) do |s|
  s.name = 'example.com'
  s.ttl = 86400
  s.primary_ns = 'ns1.example.com'
  s.contact = 'admin@example.com'
  s.refresh = 10800
  s.retry = 7200
  s.expire = 604800
  s.minimum = 10800
end

# Sample records for example.com
NS.seed( :domain_id, :content ) do |s|
  s.domain_id = Domain.find_by_name('example.com').id
  s.ttl = 86400
  s.name = '@'
  s.content = 'ns1.example.com.'
end
NS.seed( :domain_id, :content ) do |s|
  s.domain_id = Domain.find_by_name('example.com').id
  s.ttl = 86400
  s.name = '@'
  s.content = 'ns2.example.com.'
end
A.seed( :domain_id, :name ) do |s|
  s.domain_id = Domain.find_by_name('example.com').id
  s.ttl = 86400
  s.name = 'ns1'
  s.content = '10.0.0.1'
end
A.seed( :domain_id, :name ) do |s|
  s.domain_id = Domain.find_by_name('example.com').id
  s.ttl = 86400
  s.name = 'ns2'
  s.content = '10.0.0.2'
end
A.seed( :domain_id, :name ) do |s|
  s.domain_id = Domain.find_by_name('example.com').id
  s.ttl = 86400
  s.name = '@'
  s.content = '10.0.0.3'
end
MX.seed( :domain_id, :name ) do |s|
  s.domain_id = Domain.find_by_name('example.com').id
  s.ttl = 86400
  s.name = '@'
  s.prio = 10
  s.content = 'mail'
end
A.seed( :domain_id, :name ) do |s|
  s.domain_id = Domain.find_by_name('example.com').id
  s.ttl = 86400
  s.name = 'mail'
  s.content = '10.0.0.4'
end
