$: << File.dirname(__FILE__) + '/../lib'
require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require :default, :test

require 'active_support'
require 'active_record'
require 'rspec'
require 'fileutils'
require 'attribute_defaults'

USE_PROTECTED_ATTRIBUTES = ENV['FORCE_PROTECTED_ATTRIBUTES'] || ActiveRecord::VERSION::MAJOR < 4
if ENV['FORCE_PROTECTED_ATTRIBUTES']
  require 'protected_attributes'
end

ActiveRecord::Base.configurations["test"] = { 'adapter' => 'sqlite3', 'database' => ":memory:" }
ActiveRecord::Base.establish_connection :test
ActiveRecord::Base.connection.create_table :foos do |t|
  t.string   :name
  t.integer  :age
  t.string   :locale
  t.string   :description
  t.timestamps
end

class Foo < ActiveRecord::Base
  attr_accessible :name, :age, :locale if USE_PROTECTED_ATTRIBUTES
  attr_accessor   :birth_year

  attr_default    :description, "(no description)", :if => :blank?
  attr_default    :locale, "en", :persisted => false
  attr_default    :birth_year do |f|
    f.age ? Time.now.year - f.age : nil
  end
end
Foo.create!(:name => 'Bogus') {|i| i.locale = nil }

class Bar < Foo
  attr_accessor   :some_hash, :some_arr
  attr_accessible :some_arr if USE_PROTECTED_ATTRIBUTES

  attr_default    :some_hash, :default => {}
  attr_default    :some_arr, :default => [1, 2, 3], :if => :blank?
end

class Baz < ActiveRecord::Base
  self.table_name = 'foos'
  attr_defaults :description => "Please set ...", :age => { :default => 18, :persisted => false }, :locale => proc { 'en-US' }
end
