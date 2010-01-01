require 'active_record'

class Client < ActiveRecord::Base
  has_many :projects
end

class Project < ActiveRecord::Base
  has_many :tasks
  belongs_to :client
end

class Task < ActiveRecord::Base
  belongs_to :project
  has_many :time_entries
end

class TimeEntry < ActiveRecord::Base
  belongs_to :task
end

class Staff < ActiveRecord::Base
end
