$:.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib')
begin
  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "--format pretty"
  end
  task :features => 'db:test:prepare'
rescue LoadError
  # Do nothing but warn
  message = [
             "You don't have the cucumber gem installed.",
             "Unless you're developing patches for powerdns-on-rails, you can ignore this message.",
             "To learn more about cucumber, please visit the URL below",
             "http://github.com/aslakhellesoy/cucumber/wikis",
             ""
  ]
  message.each { |l| $stderr.write( l + "\n" ) }
end

