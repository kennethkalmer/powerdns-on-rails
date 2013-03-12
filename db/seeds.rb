# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# Create our admin user
user = User.find_by_email('admin@example.com') || User.new(:email => 'admin@example.com')
user.login = 'admin' # Not used anymore
user.password = 'secret'
user.password_confirmation = 'secret'
user.admin = true
user.save!
user.confirm!

# Create an example zone template
zone_template = ZoneTemplate.find_by_name('Example Template') || ZoneTemplate.new(:name => 'Example Template')
zone_template.ttl = 86400
zone_template.save!

# Clean and re-populate the zone template
zone_template.record_templates.clear

# SOA
RecordTemplate.create!({
  :zone_template => zone_template,
  :record_type => 'SOA',
  :primary_ns => 'ns1.%ZONE%',
  :contact => 'template@example.com',
  :refresh => 10800,
  :retry => 7200,
  :expire => 604800,
  :minimum => 10800
})

# NS records
RecordTemplate.create!({
  :zone_template => zone_template,
  :record_type => 'NS',
  :content => 'ns1.%ZONE%'
})
RecordTemplate.create!({
  :zone_template => zone_template,
  :record_type => 'NS',
  :content => 'ns2.%ZONE%'
})

# Assorted A records
RecordTemplate.create!({
  :zone_template => zone_template,
  :record_type => 'A',
  :name => 'ns1',
  :content => '10.0.0.1'
})
RecordTemplate.create!({
  :zone_template => zone_template,
  :record_type => 'A',
  :name => 'ns2',
  :content => '10.0.0.2'
})
RecordTemplate.create!({
  :zone_template => zone_template,
  :record_type => 'A',
  :content => '10.0.0.3'
})
RecordTemplate.create!({
  :zone_template => zone_template,
  :record_type => 'A',
  :name => 'mail',
  :content => '10.0.0.4'
})
RecordTemplate.create!({
  :zone_template => zone_template,
  :record_type => 'MX',
  :content => 'mail',
  :prio => 10
})

# And add our example.com records
domain = Domain.find_by_name('example.com') || Domain.new(:name => 'example.com')
domain.ttl = 84600
domain.primary_ns = 'ns1.example.com'
domain.contact = 'admin@example.com'
domain.refresh = 10800
domain.retry = 7200
domain.expire = 604800
domain.minimum = 10800
domain.save!

# Clear the records and start fresh
domain.records_without_soa.each(&:destroy)

# NS records
NS.create!({
  :domain => domain,
  :content => 'ns1.%ZONE%'
})
NS.create!({
  :domain => domain,
  :content => 'ns2.%ZONE%'
})

# Assorted A records
A.create!({
  :domain => domain,
  :name => 'ns1',
  :content => '10.0.0.1'
})
A.create!({
  :domain => domain,
  :name => 'ns2',
  :content => '10.0.0.2'
})
A.create!({
  :domain => domain,
  :content => '10.0.0.3'
})
A.create!({
  :domain => domain,
  :name => 'mail',
  :content => '10.0.0.4'
})
MX.create!({
  :domain => domain,
  :type => 'MX',
  :content => 'mail',
  :prio => 10
})

puts <<-EOF


-------------------------------------------------------------------------------


Congratulations on setting up your PowerDNS on Rails database. You can now
start the server by running the command below, and then pointing your browser
to http://localhost:3000/

$ ./script/rails s

You can then login with "admin@example.com" using the password "secret".

Thanks for trying out PowerDNS on Rails!


-------------------------------------------------------------------------------


EOF
