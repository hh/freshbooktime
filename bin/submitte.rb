#!/usr/bin/env ruby
##
## simplesubmit.rb
## Login : <chris@mbp.austin.rr.com>
## Started on  Wed Dec 30 18:05:13 2009 Chris McClimans
## $Id$

APPNAME = File.basename(__FILE__)
SCRIPT_PATH = Dir.chdir(File.expand_path(File.dirname(__FILE__))) { Dir.pwd }
CONF_PATH = Dir.chdir(SCRIPT_PATH + '/../conf') { Dir.pwd }
CACHE_DIR = Dir.chdir(SCRIPT_PATH + '/../cache') { Dir.pwd }
lib_path = Dir.chdir(SCRIPT_PATH + '/../lib') { Dir.pwd }

$:.unshift lib_path

require 'freshbooktime/freshbooks'
require 'freshbooktime/common'
require 'freshbooktime/timesheet'
require 'yaml'
$config = YAML.load_file(CONF_PATH + "/myconfig.yml")

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

fts = FreshTimeSheet.new($config)

timeentries = YAML.load_file(tefile)
timeentries.each do |e|
  fts.add_entry(e)
end
