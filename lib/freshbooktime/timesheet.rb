require 'freshbooktime/models'
require 'freshbooktime/cache'
class FreshTimeSheet
  attr_accessor :cache
  def initialize(config)
    FreshBooks.setup(config[:apihost],config[:apikey])
  end

  def add_entry(e=nil)
    return nil if e.nil?
    time_entry_id=0,
    project_id=Project.find_by_name(e[:proj]).project_id
    task_id=Task.find_by_name(e[:task]).task_id
    hours=e[:hours]
    notes=e[:notes]
    date=e[:date]
    #staff_id=Staff.find_by_username(e[:username])
    staff_id=nil
    puts project_id, task_id, hours, notes, date.to_s
    FreshBooks::Time_Entry.new(0,project_id,task_id,
                               hours,staff_id,notes,date.to_s).create
  end
end
