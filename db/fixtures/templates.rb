ZoneTemplate.seed( :name ) do |s|
  s.name = 'East Coast Data Center'
  s.ttl = 86400
end

zone_template = ZoneTemplate.find_by_name( 'East Coast Data Center' )

RecordTemplate.seed( :zone_template_id, :record_type, :name, :content ) do |s|
  s.zone_template_id = zone_template.id
  s.ttl = 86400
  s.record_type = 'SOA'
  s.primary_ns = 'ns1.%ZONE%'
  s.contact = 'east-coast@example.com'
  s.refresh = 10800
  s.retry = 7200
  s.expire = 604800
  s.minimum = 10800
end
RecordTemplate.seed( :zone_template_id, :record_type, :name, :content ) do |s|
  s.zone_template_id = zone_template.id
  s.ttl = 86400
  s.record_type = 'NS'
  s.content = 'ns1.%ZONE%'
end
RecordTemplate.seed( :zone_template_id, :record_type, :name, :content ) do |s|
  s.zone_template_id = zone_template.id
  s.ttl = 86400
  s.record_type = 'NS'
  s.content = 'ns2.%ZONE%'
end
RecordTemplate.seed( :zone_template_id, :record_type, :name, :content ) do |s|
  s.zone_template_id = zone_template.id
  s.ttl = 86400
  s.record_type = 'A'
  s.name = 'ns1'
  s.content = '10.0.0.1'
end
RecordTemplate.seed( :zone_template_id, :record_type, :name, :content ) do |s|
  s.zone_template_id = zone_template.id
  s.ttl = 86400
  s.record_type = 'A'
  s.name = 'ns2'
  s.content = '10.0.0.2'
end
RecordTemplate.seed( :zone_template_id, :record_type, :name, :content ) do |s|
  s.zone_template_id = zone_template.id
  s.ttl = 86400
  s.record_type = 'A'
  s.content = '10.0.0.3'
end
RecordTemplate.seed( :zone_template_id, :record_type, :name, :content ) do |s|
  s.zone_template_id = zone_template.id
  s.ttl = 86400
  s.record_type = 'A'
  s.name = 'mail'
  s.content = '10.0.0.4'
end
RecordTemplate.seed( :zone_template_id, :record_type, :name, :content ) do |s|
  s.zone_template_id = zone_template.id
  s.ttl = 86400
  s.record_type = 'MX'
  s.content = 'mail'
  s.prio = 10
end