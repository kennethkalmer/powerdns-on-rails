# Seed data for BIND DLZ on Rails, just to get you started.

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
end
User.find_by_login('admin').roles << Role.find_by_name('admin')

# Sample zone
Zone.seed( :name ) do |s|
  s.name = 'example.com'
  s.ttl = 86400
end

# Sample records for example.com
SOA.seed( :zone_id, :primary_ns ) do |s|
  s.zone_id = Zone.find_by_name('example.com').id
  s.ttl = 86400
  s.host = '@'
  s.primary_ns = 'ns1.example.com.'
  s.contact = 'admin.example.com'
  s.serial = '2008040101'
  s.refresh = 10800
  s.retry = 7200
  s.expire = 604800
  s.minimum = 10800
end
NS.seed( :zone_id, :data ) do |s|
  s.zone_id = Zone.find_by_name('example.com').id
  s.ttl = 86400
  s.host = '@'
  s.data = 'ns1.example.com.'
end
NS.seed( :zone_id, :data ) do |s|
  s.zone_id = Zone.find_by_name('example.com').id
  s.ttl = 86400
  s.host = '@'
  s.data = 'ns2.example.com.'
end
A.seed( :zone_id, :host ) do |s|
  s.zone_id = Zone.find_by_name('example.com').id
  s.ttl = 86400
  s.host = 'ns1'
  s.data = '10.0.0.1'
end
A.seed( :zone_id, :host ) do |s|
  s.zone_id = Zone.find_by_name('example.com').id
  s.ttl = 86400
  s.host = 'ns2'
  s.data = '10.0.0.2'
end
A.seed( :zone_id, :host ) do |s|
  s.zone_id = Zone.find_by_name('example.com').id
  s.ttl = 86400
  s.host = '@'
  s.data = '10.0.0.3'
end
MX.seed( :zone_id, :host ) do |s|
  s.zone_id = Zone.find_by_name('example.com').id
  s.ttl = 86400
  s.host = '@'
  s.priority = 10
  s.data = 'mail'
end
A.seed( :zone_id, :host ) do |s|
  s.zone_id = Zone.find_by_name('example.com').id
  s.ttl = 86400
  s.host = 'mail'
  s.data = '10.0.0.4'
end
