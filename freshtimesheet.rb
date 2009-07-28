require 'freshbooks'
require "erb"


class FreshTime
  def initialize(config)
    FreshBooks.setup(config['apihost'],config['apikey'])
  end
  def timesheet_for_client(client_id,from_date,to_date)
    weeklyhours=0
    ts={}
    FreshBooks::Project.list([['client_id', client_id],]).each do |p|
      FreshBooks::Task.list([['project_id', p.project_id],]).each do |t|
        FreshBooks::Time_Entry.list([
                                      ['date_from', from_date],
                                      ['date_to', to_date],
                                      ['task_id',t.task_id],
                                      ['project_id',p.project_id],
                                     ]).each do |e|
          weeklyhours += e.hours
          if not ts[e.date]:
              ts[e.date] = [[e.hours,p.name,e.notes],]
          else
              ts[e.date] << [e.hours,p.name,e.notes]
          end
        end
      end
    end
    # ts.each do |day,times|
    #   times.each do |hours,proj,desc|
    #     puts "#{day} #{hours} #{proj} #{desc.inspect}"
    #   end
    # end
    #puts "Weekly Total For #{from_date} to #{to_date}: #{weeklyhours}"
    return ({:weekly_timesheet=>ts,:weekly_total=>weeklyhours})
  end
end
