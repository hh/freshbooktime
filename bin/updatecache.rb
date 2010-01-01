#!/usr/bin/env ruby
require 'active_record'
require 'lib/freshbooktime/freshbooks'
require 'yaml'
script_path = Dir.chdir(File.expand_path(File.dirname(__FILE__))) { Dir.pwd }
lib_path = Dir.chdir(script_path + '/../lib') { Dir.pwd }
conf_path = Dir.chdir(script_path + '/../conf') { Dir.pwd }
cache_path = Dir.chdir(script_path + '/../cache') { Dir.pwd }
$:.unshift lib_path

$config = YAML.load_file(conf_path + "/myconfig.yml")

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = true # false
ActiveRecord::Base.establish_connection(
                                        :adapter => "sqlite3",
                                        :dbfile  => cache_path+"/db" #:memory:"
                                        )
#require 'freshbooktime/schema'
#require 'freshbooktime/models'
require 'freshbooktime/cache'


t=FreshTimeCache.new($config)
t.cache_clients
t.cache_staff
t.cache_time
