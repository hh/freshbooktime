require 'active_record'
require 'lib/freshbooktime/freshbooks'
require 'yaml'
$config = YAML.load_file(File.join(File.dirname(__FILE__),
                                   "./conf/myconfig.yml"))

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = true # false
ActiveRecord::Base.establish_connection(
                                        :adapter => "sqlite3",
                                        :dbfile  => ":memory:"
                                        )

ActiveRecord::Schema.define do
  create_table :clients do |t|
    t.integer  "client_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "organization"
    t.string   "email"
    t.string   "username"
    t.string   "password"
    t.string   "work_phone"
    t.string   "home_phone"
    t.string   "mobile"
    t.string   "fax"
    t.text     "notes"
    t.string   "p_street1"
    t.string   "p_street2"
    t.string   "p_city"
    t.string   "p_state"
    t.string   "p_country"
    t.string   "p_code"
    t.string   "s_street1"
    t.string   "s_street2"
    t.string   "s_city"
    t.string   "s_state"
    t.string   "s_country"
    t.string   "s_code"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table :projects do |t|
    t.integer  "project_id"
    t.integer  "client_id"
    t.string   "name"
    t.string   "bill_method"
    t.decimal  "rate"
    t.string   "description"
    t.integer  "tasks"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table :staffs do |t|
    t.integer  "staff_id"
    t.string   "username"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "business_phone"
    t.string   "mobile_phone"
    t.string   "rate"
    t.string   "last_login"
    t.integer  "number_of_logins"
    t.string   "signup_date"
    t.string   "street1"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table :tasks do |t|
    t.integer  "task_id"
    t.string   "name"
    t.boolean  "billable"
    t.decimal  "rate"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table :time_entries do |t|
    t.integer  "time_entry_id"
    t.integer  "project_id"
    t.integer  "task_id"
    t.integer  "staff_id"
    t.decimal  "hours"
    t.string   "notes"
    t.string   "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

class Client < ActiveRecord::Base
  has_many :projects
end

class Project < ActiveRecord::Base
  has_many :tasks
  belongs_to :projects
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

class FreshTimeCache
  attr_accessor :cache
  def initialize
    FreshBooks.setup($config['apihost'],$config['apikey'])
  end

  def cache_clients
    FreshBooks::Client.list.each do |c|
      Client.create(:client_id => c.client_id,
                    :first_name => c.first_name,
                    :last_name => c.last_name,
                    :organization => c.organization,
                    :email => c.email,
                    :username => c.username,
                    :password => c.password,
                    :work_phone => c.work_phone,
                    :home_phone => c.home_phone,
                    :mobile => c.mobile,
                    :fax => c.fax,
                    :notes => c.notes,
                    :p_street1 => c.p_street1,
                    :p_street2 => c.p_street2,
                    :p_city => c.p_city,
                    :p_state => c.p_state,
                    :p_country => c.p_country,
                    :p_code => c.p_code,
                    :s_street1 => c.s_street1,
                    :s_street2 => c.s_street2,
                    :s_city => c.s_city,
                    :s_state => c.s_state,
                    :s_country => c.s_country,
                    :s_code => c.s_code,
                    :url => c.url)
      FreshBooks::Project.list([['client_id', c.client_id],]).each do |p|
        # need to figure out how to link client_id to Client
        Project.create(
                       :project_id => p.project_id,
                       :client_id => p.client_id,
                       :name => p.name,
                       :bill_method => p.bill_method,
                       :rate => p.rate,
                       :description => p.description
                       # these seem to always be empty!
                       # :tasks => p.tasks
                       )
        FreshBooks::Task.list([['project_id', p.project_id],]).each do |t|
          # need to figure out how to link back to project
          Task.create(
                      :task_id => t.task_id,
                      :name => t.name,
                      :billable => t.billable,
                      :rate => t.rate,
                      :description => t.description
                      )
        end
      end
    end
  end

  def cache_staff
    FreshBooks::Staff.list.each do |s|
      Staff.create(
                   :staff_id => s.staff_id,
                   :username => s.username,
                   :first_name => s.first_name,
                   :last_name => s.last_name,
                   :email => s.email,
                   :business_phone => s.business_phone,
                   :mobile_phone => s.mobile_phone,
                   :rate => s.rate,
                   :last_login => s.last_login,
                   :number_of_logins => s.number_of_logins,
                   :signup_date => s.signup_date,
                   :street1 => s.street1,
                   :street2 => s.street2,
                   :city => s.city,
                   :state => s.state,
                   :country => s.country,
                   :code => s.code
                   )
    end
  end

  def cache_time
    'need to figure out how to interlink'
    timelist = []
    timepage = FreshBooks::Time_Entry.list
    page = 1
    until timepage.empty?
      timelist += timepage
      page += 1
      timepage = FreshBooks::Time_Entry.list([['page',page],])
    end
    timelist.each do |t|
      TimeEntry.create(
                       :time_entry_id => t.time_entry_id,
                       :project_id => t.project_id,
                       :task_id => t.task_id,
                       :hours => t.hours,
                       :notes => t.notes,
                       :date => t.date
                       )
    end
  end
end


t=FreshTimeCache.new
t.cache_clients
t.cache_staff
t.cache_time
puts Client.all
puts Project.all
puts Task.all
puts TimeEntry.all
