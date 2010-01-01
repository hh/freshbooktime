##
## simplesubmit.rb
## Login : <chris@mbp.austin.rr.com>
## Started on  Wed Dec 30 18:05:13 2009 Chris McClimans
## $Id$

require './lib/freshbooktime/freshbooks'
require 'yaml'
$config = YAML.load_file(File.join(File.dirname(__FILE__),
                                   "./conf/myconfig.yml"))
require 'active_record'

ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.colorize_logging = false
ActiveRecord::Base.establish_connection(
                                        :adapter => "sqlite3",
                                        :dbfile  => "./db" #:memory:"
                                        )
class Client < ActiveRecord::Base
  has_many :projects
end

class Project < ActiveRecord::Base
  has_many :tasks
  belongs_to :client
end

class Task < ActiveRecord::Base
  belongs_to :project
end

class Staff < ActiveRecord::Base
end

class TimeEntry < ActiveRecord::Base
  belongs_to :project
  belongs_to :task
end


tt=TimeEntry.find_all_by_staff__id(
          Staff.find_by_username('taylor').staff_id,
                                   :conditions => {
                                     :date => Date::civil(2009,12,1) ..
                                     Date::civil(2009,12,31),}
                                   )
# Findd project_id and task_id from Project.list and Task.list
# Returns the time_entry_id


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
