[![Build Status](https://travis-ci.org/openSUSE/rubygem_config-parser.png?branch=master)](https://travis-ci.org/openSUSE/rubygem_config-parser)

## Ruby Config Parser

Providing config values for your Ruby app with convenience methods like
overwriting variables per Rails environment and overwriting variables with a local
options_local.yml file.

### Installation

The best way to install is with [RubyGems](https://rubygems.org/gems/config-parser):

    $ gem install config-parser

Or better still, just add it to your `Gemfile`:

    gem 'config-parser'

### Defaults

Per default the parser will search for the config file at `config/options.yml` and local overrides at `config/options-local.yml`.


### Example

Example config file:

    default:
      supported_languages: en
      mailer_delivery_method: local

    production:
      mailer_delivery_method: smtp

When running in the production environment, the mailer_delivery_method will be set to
'smtp'. The same works for all other environments. The optional options_local.yml file
would have the same layout.

The precedence of config values goes like this (from lowest to highest):

`options.yml default section -> options.yml environment section -> options-local.yml default section -> options-local.yml environment section`

When used from a Rails app, just include in your `application.rb`:

```ruby
OPTS = Common::Options.new
```

and you can use the config variables like:

```ruby
OPTS.<variable_name>
OPTS.<variable_name>[:nested_value]
```

Also, you can pass main config and local config location as well as environment to load
That allows you to use config-parser outside Rails env.

```ruby
OPTS = Common::Options.new('path/to/options.yml', 'path/to/options-local.yml', :development)
```
