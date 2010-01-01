#!/usr/bin/env ruby

script_path = Dir.chdir(File.expand_path(File.dirname(__FILE__))) { Dir.pwd }
lib_path = Dir.chdir(script_path + '/../lib') { Dir.pwd }
conf_path = Dir.chdir(script_path + '/../conf') { Dir.pwd }
CACHE_DIR = Dir.chdir(script_path + '/../cache') { Dir.pwd }
$:.unshift lib_path

#require 'active_record'
require 'freshbooktime/freshbooks'
require 'freshbooktime/schema' # module to create schema
require 'freshbooktime/models'
require 'freshbooktime/cache'
require 'yaml'

$config = YAML.load_file(conf_path + "/myconfig.yml")

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = true # false
ActiveRecord::Base.establish_connection(
                                        :adapter => "sqlite3",
                                        :database  => CACHE_DIR + "/db" #:memory:"
                                        )
FreshTimeCacheSchema.create

t=FreshTimeCache.new
t.cache_clients
t.cache_staff
t.cache_time
# puts Client.all.length
# puts Project.all.length
# puts Task.all.length
# puts TimeEntry.all.length
#catalis = Client.all[3]
#puts "catilis project 0 task 0 task_id", catalis.projects[3].tasks[0].task_id
