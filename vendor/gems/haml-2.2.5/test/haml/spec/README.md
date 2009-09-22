# Haml Spec #

Haml Spec provides a basic suite of tests for Haml interpreters.

It is intented for developers who are creating or maintaining an
implementation of the [Haml](http://haml-lang.com) markup language.

At the moment, there are test runners for the [original Haml](http://github.com/nex3/haml)
in Ruby, and for [Lua Haml](http://github.com/norman/lua-haml). Support for
other versions of Haml will be added if their developers/maintainers
are interested in using it.

## The Tests ##

The tests are kept in JSON format for portability across languages.
Each test is a simple key/value pair of input and expected output.
The test suite only provides tests for features which are portable,
therefore no tests for script are provided, nor for external filters
such as :markdown or :textile.

## Running the Tests ##

### Ruby ###

The Ruby test uses RSpec, so just install the gem and run `spec ruby_haml_spec.rb`.
I have only tested it against Ruby 1.9; if you want to run it on an older Ruby
you'll need to install the "json" gem.

### Lua ###

The Lua test depends on [Telescope](http://telescope.luaforge.net/),
[jason4lua](http://json.luaforge.net/), and
[Lua Haml](http://github.com/norman/lua-haml). Install and
run `tsc lua_haml_spec.lua`.

## Contributing ##

You can access the Git repo at:

    http://github.com/norman/haml-spec

As long as any test you add run against Ruby's Haml and are not redundant,
I'll be very happy to add them.

## License ##

This project is released under the [WTFPL](http://sam.zoy.org/wtfpl/)
in order to be as usable as possible in any project, commercial or free.


## Author ##

[Norman Clarke](mailto:norman@njclarke.com)
