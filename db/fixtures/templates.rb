ZoneTemplate.seed( :name ) do |s|
  s.name = 'East Coast Data Center'
  s.ttl = 86400
end

zone_template = ZoneTemplate.find_by_name( 'East Coast Data Center' )

RecordTemplate.seed( :zone_template_id, :record_type, :host, :data ) do |s|
  s.zone_template_id = zone_template.id
  s.ttl = 86400
  s.record_type = 'SOA'
  s.host = '@'
  s.primary_ns = 'ns1.%ZONE%.'
  s.contact = 'east-coast.example.com'
  s.refresh = 10800
  s.retry = 7200
  s.expire = 604800
  s.minimum = 10800
end
RecordTemplate.seed( :zone_template_id, :record_type, :host, :data ) do |s|
  s.zone_template_id = zone_template.id
  s.ttl = 86400
  s.record_type = 'NS'
  s.host = '@'
  s.data = 'ns1.%ZONE%.'
end
RecordTemplate.seed( :zone_template_id, :record_type, :host, :data ) do |s|
  s.zone_template_id = zone_template.id
  s.ttl = 86400
  s.record_type = 'NS'
  s.host = '@'
  s.data = 'ns2.%ZONE%.'
end
RecordTemplate.seed( :zone_template_id, :record_type, :host, :data ) do |s|
  s.zone_template_id = zone_template.id
  s.ttl = 86400
  s.record_type = 'A'
  s.host = 'ns1'
  s.data = '10.0.0.1'
end
RecordTemplate.seed( :zone_template_id, :record_type, :host, :data ) do |s|
  s.zone_template_id = zone_template.id
  s.ttl = 86400
  s.record_type = 'A'
  s.host = 'ns2'
  s.data = '10.0.0.2'
end
RecordTemplate.seed( :zone_template_id, :record_type, :host, :data ) do |s|
  s.zone_template_id = zone_template.id
  s.ttl = 86400
  s.record_type = 'A'
  s.host = '@'
  s.data = '10.0.0.3'
end
RecordTemplate.seed( :zone_template_id, :record_type, :host, :data ) do |s|
  s.zone_template_id = zone_template.id
  s.ttl = 86400
  s.record_type = 'A'
  s.host = 'mail'
  s.data = '10.0.0.4'
end
RecordTemplate.seed( :zone_template_id, :record_type, :host, :data ) do |s|
  s.zone_template_id = zone_template.id
  s.ttl = 86400
  s.record_type = 'MX'
  s.host = '@'
  s.data = 'mail'
  s.priority = 10
end