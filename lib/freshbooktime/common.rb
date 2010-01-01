require 'rubygems'
require 'active_record'

#def get_script_path(f=nil)
#  #Dir.chdir(File.expand_path(File.dirname(__FILE__))) { Dir.pwd }
#  Dir.chdir(File.expand_path(File.dirname(f))) { Dir.pwd }
#end

def get_app_paths(f=nil)
  #Dir.chdir(File.expand_path(File.dirname(__FILE__))) { Dir.pwd }
  script_dir = Dir.chdir(File.expand_path(File.dirname(f))) { Dir.pwd }
  conf_dir = Dir.chdir(script_dir + '/../conf') { Dir.pwd }
  cache_dir = Dir.chdir(script_dir + '/../cache') { Dir.pwd }
  lib_dir = Dir.chdir(script_path + '/../lib') { Dir.pwd }
  [script_dir, conf_dir, cache_dir, lib_dir]
end

ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.colorize_logging = false
ActiveRecord::Base.establish_connection( :adapter => "sqlite3", :database  => CACHE_DIR + "/db" )
true
