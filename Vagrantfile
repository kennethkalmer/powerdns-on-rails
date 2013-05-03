# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "pdns-on-rails-precise64"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://aussie.lunix.com.au/files/vagrantboxes/pdns-on-rails-precise64.box"
  config.vm.provision :shell, :path => "script/provision"
end
