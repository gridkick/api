ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)

# Removed `hell` because it breaks w/ Mocha
require "minitest/autorun"
require "minitest/rails"
require "minitest/pride"

Dir[ "#{ File.dirname __FILE__ }/support/**/*.rb" ].each { | f | require f }

Fog.mock!

require 'mocha/setup'
