config.gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com'

config.after_initialize do
  %w(test spec).each do |dir|
    factories = File.join(RAILS_ROOT, dir, 'factories.rb')
    require factories if File.exists?(factories)
    Dir[File.join(RAILS_ROOT, dir, 'factories', '*.rb')].each do |file|
      require file
    end
  end  
end