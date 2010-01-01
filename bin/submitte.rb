#!/usr/bin/env ruby
##
## simplesubmit.rb
## Login : <chris@mbp.austin.rr.com>
## Started on  Wed Dec 30 18:05:13 2009 Chris McClimans
## $Id$

script_path = Dir.chdir(File.expand_path(File.dirname(__FILE__))) { Dir.pwd }
lib_path = Dir.chdir(script_path + '/../lib') { Dir.pwd }
conf_path = Dir.chdir(script_path + '/../conf') { Dir.pwd }
$:.unshift lib_path

APPNAME = File.basename(__FILE__)

require 'freshbooktime/freshbooks'
require 'freshbooktime/models'
require 'yaml'
$config = YAML.load_file(conf_path + "/myconfig.yml")


def usage
  "usage: #{APPNAME} <timeentry yaml>"
end
def die(*s)
  puts s
  exit 1
end

case ARGV[0]
when "-h", "--help", "-help"
  puts usage
  exit
end

tefile = ARGV[0] || die("ERROR: no time entry file given\n" + usage)

ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.colorize_logging = false
ActiveRecord::Base.establish_connection(
                                        :adapter => "sqlite3",
                                        :dbfile  => "./db" #:memory:"
                                        )

FreshBooks.setup($config['apihost'],$config['apikey'])
# puts FreshBooks::Time_Entry.new( time_entry_id=0, project_id=10, task_id=7,
#                             hours=4,
#                             notes="Long Entry",
#                             date="2009-12-01").create
# puts FreshBooks::Time_Entry.new( 0, 10, 7,
#                             4,"Shorthand","2009-12-01").create

YAML.load_file('ts.yaml').each do |e|
  FreshBooks::Time_Entry.new(
                         time_entry_id=0,
                         project_id=Project.find_by_name(
                                                   e[:proj]).project_id,
                         task_id=Task.find_by_name(
                                                   e[:task]).task_id,
                             hours=e[:hours],
                             notes=e[:notes],
                             date=e[:date]).create
end
