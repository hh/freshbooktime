#FIXME: this should check to see if cache already exists
#require 'freshbooktime/schema'
require 'freshbooktime/models'
class FreshTimeCache
  attr_accessor :cache
  def initialize(config)
    FreshBooks.setup(config[:apihost],config[:apikey])
  end

  def cache_clients
    FreshBooks::Client.list.each do |c|
      c = Client.create(
                    :client_id => c.client_id,
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
        p = Project.create(
                       :client => c,
                       :client__id => p.client_id,
                       :project_id => p.project_id,
                       :name => p.name,
                       :bill_method => p.bill_method,
                       :rate => p.rate,
                       :description => p.description
                       # these seem to always be empty!
                       # :tasks => p.tasks
                       )
        FreshBooks::Task.list([['project_id', p.project_id],]).each do |t|
          Task.create(
                      :project => p,
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
                       :staff => Staff.find_by_staff_id(t.staff_id),
                       :project => Project.find_by_project_id(t.project_id),
                       :task => Task.find_by_task_id(t.task_id),
                       :time_entry_id => t.time_entry_id,
                       :staff__id => t.staff_id,
                       :project__id => t.project_id,
                       :task__id => t.task_id,
                       :hours => t.hours,
                       :notes => t.notes,
                       :date => t.date
                       )
    end
  end
end
