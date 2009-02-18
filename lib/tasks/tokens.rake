require 'erb'

desc "Generate example authentication tokens"
task :tokens => :environment do
  puts ""
  puts "Generating tokens"
  puts
  
  # Parse each token
  Dir["doc/examples/tokens/*.erb"].each do |erb|
    xml_file = File.basename(erb, '.erb')
    File.open("tmp/token_#{xml_file}", "w+") do |f|
      f.write( ERB.new( File.read( erb ) ).result( binding ) )
    end

    puts "* Generated token: tmp/token_#{xml_file}"
  end

  puts <<-EOF

To use the example tokens, please make sure you have seeded the database by
running 'rake db:seed'.

To execute a token, you can use the following curl command:

  curl -X POST --basic -u token:secret -d @tmp/token_read_only.xml -H "Content-type: text/xml" http://localhost:3000/auth_token.xml

EOF
end
