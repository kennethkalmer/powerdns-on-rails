# Important update

The current master branch of the PowerDNS on Rails project is in turmoil as we fast-forward the project into the future.
The _very_ old previous release can be found in the 'rails-2.3.3' branch.

Thanks for your support and understanding.

# PowerDNS on Rails

[![Build Status](https://travis-ci.org/kennethkalmer/powerdns-on-rails.png?branch=master)](https://travis-ci.org/kennethkalmer/powerdns-on-rails)
[![Code Climate](https://codeclimate.com/github/kennethkalmer/powerdns-on-rails.png)](https://codeclimate.com/github/kennethkalmer/powerdns-on-rails)
[![Dependency Status](https://gemnasium.com/kennethkalmer/powerdns-on-rails.png)](https://gemnasium.com/kennethkalmer/powerdns-on-rails)

PowerDNS on Rails is a Ruby on Rails application made to manage [PowerDNS](http://www.powerdns.com/) installations using the generic MySQL/PostgreSQL backends.

More information:

* The README (this file)
* [Home page](http://kennethkalmer.github.com/powerdns-on-rails)
* [Bug tracker](http://github.com/kennethkalmer/powerdns-on-rails/issues)

## Quick Installation

_Instructions for running a demo version with Vagrant is provided further down._

    $ git clone git://github.com/kennethkalmer/powerdns-on-rails.git
    $ cd powerdns-on-rails
    $ bundle install
    $ cp config/database.yml.template config/database.yml

Review config/database.yml and modify as needed. By default it will use the MySQL connection settings.

    $ bundle exec rake generate_secret_token db:setup
    $ bundle exec rails s

Point your browser to http://localhost:3000, and login with 'admin@example.com' and 'secret'.

_Note on versions:_ PowerDNS on Rails is version-less, and the master branch will _nearly_ always have stable useable code.

## Features (current and planned)

* RESTful architecture to support rich UI and API access
* Multi-user support (admins, owners, API clients)
* CLI clients to show integration capabilities
* Conversion and import tools
* Zone/Record Templates
* DNS Insight
* Full audit record of all changes
* Macros for easy bulk updating of domains
* Support for PowerDNS MASTER, NATIVE & SLAVE record types

## Overview

PowerDNS is a reliable alternative to BIND and sports a flexible, feature rich
design and support for various backends, including MySQL and PostgreSQL. This
simplifies the management of thousands of zones, and provides added redundancy
(by way of database replication) and opens the doors for web frontends that ease
this even more.

PowerDNS on Rails is built based on our experience of managing thousands of DNS
records through various (often crude) techniques, that included building zone
files from databases via cron, and implementing PowerDNS for its database backends.

We first built BIND DLZ on Rails that allowed us to migrate back to BIND using a
MySQL 5.0 backend, but after several failed production runs we decided to split
the project off to use our existing PowerDNS infrastructure.  Using Rails 2 for
a interface just makes sense because we can build a rich interface and an REST
API in a single go. We have a lot of integration needs, and this was our main
driver.

## Demo with Vagrant

There is now a vagrant/virtualbox demo environment included.

### Requirements

You will need to have [virtualbox](https://www.virtualbox.org/) and [vagrant](http://www.vagrantup.com) already installed.

### Running locally

Once you have Vagrant installed, you can follow these steps:

    $ git clone git://github.com/kennethkalmer/powerdns-on-rails.git
    $ cd powerdns-on-rails
    $ vagrant up

Once this command completes, you can access the powerdns-on-rails by pointing your browser to http://localhost:8080 and logging in with 'admin@example.com' & secret.

The first time you run this it will download a base virtual machine and bootstrap a working powerdns-on-rails system. This might take some time, use some storage space (~2GB) and bandwidth (~500MB).

Please note that this is just a demo, we don't install or configure PowerDNS itself in the VM.

## PowerDNS Information

The PowerDNS project can be found at http://www.powerdns.com/. The documentation
is in-depth on that site, I won't repeat anything here unless its related to
this project specifically.

It is however worth noting that this interface excepts the "Generic MySQL and
PgSQL backend" to be used, as per http://doc.powerdns.com/generic-mypgsql-backends.html

## Database Structure

PowerDNS does not allow you to alter the database schema at all, and you're
forced to use at least one set database table. It can however handle additions
to the table without problems.

We also add several additional tables to accomodate users, templates, macros
and other features.

## Migration to PowerDNS

PowerDNS does provide a suite of migration tools, and they're all covered in
the official documentation.

## Testing

PowerDNS on Rails is built using extensive RSpec suites, often termed "Behaviour
Driven Development". It is critical for a core service like DNS to be reliable
and that all changes are correct and won't impact services offered to clients.

Apart from the extensive programmatic tests, we'll be implementing tests that
actually seed a DNS database and use BIND's dig utility to query a configured
PowerDNS installation.

