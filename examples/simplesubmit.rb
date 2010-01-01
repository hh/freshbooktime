##
## simplesubmit.rb
## Login : <chris@mbp.austin.rr.com>
## Started on  Wed Dec 30 18:05:13 2009 Chris McClimans
## $Id$

require '../lib/freshbooktime/freshbooks'
require 'yaml'
$config = YAML.load_file(File.join(File.dirname(__FILE__),
                                   "../conf/myconfig.yml"))

# Findd project_id and task_id from Project.list and Task.list
# Returns the time_entry_id


FreshBooks.setup($config['apihost'],$config['apikey'])
# puts FreshBooks::Time_Entry.new( time_entry_id=0, project_id=10, task_id=7,
#                             hours=4,
#                             notes="Long Entry",
#                             date="2009-12-01").create
# puts FreshBooks::Time_Entry.new( 0, 10, 7,
#                             4,"Shorthand","2009-12-01").create
require 'pp'
YAML.load_file('ts.yaml').each do |e|
  pp e
  # FreshBooks::Time_Entry.new( time_entry_id=0,
  #                             project_id=10,
  #                             task_id=7,
  #                             hours=4,
  #                             notes="Long Entry",
  #                             date="2009-12-01").create
end
