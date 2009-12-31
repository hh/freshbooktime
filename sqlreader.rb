require 'active_record'
require 'lib/freshbooktime/freshbooks'
require 'yaml'
$config = YAML.load_file(File.join(File.dirname(__FILE__),
                                   "./conf/myconfig.yml"))

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = true # false
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


TimeEntry.find_all_by_staff__id(
          Staff.find_by_username('taylor').staff_id,
          :conditions => {
            :date => Date::civil(2009,12,1) .. Date::civil(2009,12,31),
                          }
                                )
