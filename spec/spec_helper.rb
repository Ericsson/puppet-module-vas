require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |config|
  config.hiera_config = 'spec/fixtures/hiera/hiera.yaml'
  config.before :each do
    Puppet[:parser] = 'future' if ENV['PARSER'] == 'future'
  end
end
