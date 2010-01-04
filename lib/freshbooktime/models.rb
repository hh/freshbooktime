require 'rubygems'
require 'active_record'

class Client < ActiveRecord::Base
  has_many :projects
end

class Project < ActiveRecord::Base
  belongs_to :client
  has_many :tasks
  has_many :time_entries
end

class Task < ActiveRecord::Base
  belongs_to :project
  has_many :time_entries
end

class Staff < ActiveRecord::Base
  has_many :time_entries
end

class TimeEntry < ActiveRecord::Base
  belongs_to :project
  belongs_to :task
  belongs_to :staff
end

