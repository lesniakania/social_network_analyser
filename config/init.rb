begin
  # Try to require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  
  require 'rake'
  require 'rake/clean'
  require 'rake/gempackagetask'
  require 'rake/rdoctask'
  require 'rake/testtask'

  Bundler.setup
end

# Your application's requires come here, e.g.
# require 'date' # a ruby standard library
# require 'rack' # a bundled gem

# Alternatively, you can require all the bundled libs at once
# Bundler.require

require 'spec/rake/spectask'
require 'yamler'
require 'sequel'

module DataBase
  CONFIG = Yamler.load('./config/database.yml')
end
