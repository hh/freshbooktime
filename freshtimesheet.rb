require 'freshbooks'
require 'yaml'
$config = YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))
require "erb"


CATALIS_ID=13

class FreshTime
  def initialize
    FreshBooks.setup($config['apihost'],$config['apikey'])
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
    ts.each do |day,times|
      times.each do |hours,proj,desc|
        puts "#{day} #{hours} #{proj} #{desc.inspect}"
      end
    end
    puts "Weekly Total For #{from_date} to #{to_date}: #{weeklyhours}"
    return ({:weekly_timesheet=>ts,:weekly_total=>weeklyhours})
  end
end

t=FreshTime.new
#puts "projects by client"
#t.projects_by_client

puts "Timesheet for Catalis:"
total=0
weeklist={}
[['2009-07-01','2009-07-04'],['2009-07-05','2009-07-11'],['2009-07-12','2009-07-15']].each do |start,stop|
  ts=t.timesheet_for_client(CATALIS_ID,start,stop)
  total+=ts[:weekly_total]
  weeklist[[start,stop]]=ts
end
namespace={
    :totalhours => total,
    :weeksheets => weeklist
}


puts namespace.inspect

# Create template.
namespace={:totalhours=>84.75, :weeksheets=>{["2009-07-12", "2009-07-15"]=>{:weekly_timesheet=>{"2009-07-12"=>[[0.5, "Faxing", "Attempted to work on faxing, discovered that qaca06 is shut down on the weekends due to air conditioning requirements, which stopped further testing."]], "2009-07-13"=>[[0.5, "Clinic Support", "Browser Issue"], [4.0, "Faxing", "Debugged receive fax problem. Moved onto integration coverpage."], [0.5, "General Support", "Staff Support"]], "2009-07-14"=>[[4.0, "ASP", "Started migration of our application to  virtualized solution"], [1.0, "Clinic Support", "Started on script to map degraded clinics"]], "2009-07-15"=>[[9.0, "ASP", "Asp Meetings, Research, and collaborative discussions on architecture."], [2.5, "Faxing", "Meeting and discussion with Duffy"], [1.5, "General Support", "Wednesday Weekly Meeting"]]}, :weekly_total=>23.5}, ["2009-07-05", "2009-07-11"]=>{:weekly_timesheet=>{"2009-07-06"=>[[8.0, "Clinic Support", "Briggs Clinic Install VPN Issue"], [2.25, "General Support", "Dev Meeting and folllow up"]], "2009-07-07"=>[[1.0, "Clinic Support", "Meeting about VPN Issue"], [4.0, "Clinic Support", "Continuation of Briggs VPN Issue"], [2.0, "Faxing", "Pairing on Faxing Development"]], "2009-07-08"=>[[1.5, "ASP", "Certificate Authority Research"], [4.0, "Faxing", "Framing"], [2.0, "General Support", "Midweek Meetings"]], "2009-07-09"=>[[9.0, "Faxing", "Faxing Development"], [1.0, "General Support", "Backup Server Colo Visit and reboot of Q."], [1.0, "General Support", "Diagnosing network issues"]], "2009-07-10"=>[[3.0, "Faxing", "Con call with Sfax, working with Caleb on integration with Accelerator."], [1.0, "General Support", "Group Meeting"]]}, :weekly_total=>39.75}, ["2009-07-01", "2009-07-04"]=>{:weekly_timesheet=>{"2009-07-01"=>[[2.0, "Faxing", "Further Debugging"], [6.0, "General Support", "Multiple Meetings\nStaff support issues\nInfrastructure support (Trac)"]], "2009-07-02"=>[[2.0, "Faxing", "Further Debugging"], [3.5, "General Support", "Catalis Trac Upgrades and Maintenance"]], "2009-07-03"=>[[8.0, "General Support", "Meetings (staff,penman update)\nInfrastructure and internal support"]]}, :weekly_total=>21.5}}}
template = %q{
  Timesheet for Chris McClimans:

  % namespace[:weeksheets].each do |range,timesheet|
    % week_start = range[0]
    % week_end = range[1]
    % weekly_total = timesheet[:weekly_total]
    % timesheet[:weekly_timesheet].each do |date,entries|
      % entries.each do |hours,project,note|
          <%= date,hours,project,note %>
      % end
    % end
  % end

  Total:  <%= namespace[:totalhours] %>
  }.gsub(/^  /, '')

message = ERB.new(template, 0, "%<>")
puts message.result
