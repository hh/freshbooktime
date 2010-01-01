#!/usr/bin/env ruby

APPNAME = File.basename(__FILE__)
SCRIPT_PATH = Dir.chdir(File.expand_path(File.dirname(__FILE__))) { Dir.pwd }
CONF_PATH = Dir.chdir(SCRIPT_PATH + '/../conf') { Dir.pwd }
CACHE_DIR = Dir.chdir(SCRIPT_PATH + '/../cache') { Dir.pwd }
lib_path = Dir.chdir(SCRIPT_PATH + '/../lib') { Dir.pwd }

$:.unshift lib_path

#require 'active_record'
require 'freshbooktime/freshbooks'
require 'freshbooktime/schema' # module to create schema
require 'freshbooktime/models'
require 'freshbooktime/cache'
require 'yaml'

$config = YAML.load_file(CONF_PATH + "/myconfig.yml")

# FIXME: Don't delete unless you pass an option?
puts "Removing existing db and creating new one"
dbfile=CACHE_DIR+"/db"
File.delete(dbfile) if File.exists?(dbfile)

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = true # false
ActiveRecord::Base.establish_connection( :adapter => "sqlite3", :database  => dbfile)

FreshTimeCacheSchema.create

puts "Creating schema in #{dbfile}"

t=FreshTimeCache.new($config)

t.cache_clients
t.cache_staff
t.cache_time
# puts Client.all.length
# puts Project.all.length
# puts Task.all.length
# puts TimeEntry.all.length
#catalis = Client.all[3]
#puts "catilis project 0 task 0 task_id", catalis.projects[3].tasks[0].task_id
