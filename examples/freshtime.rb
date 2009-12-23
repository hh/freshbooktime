require 'freshbooks'
require "erb"

class FreshTime
  #push.nil
  #pull.cache
  attr_accessor :cache
  attr_accessor :cachefile
  def initialize(config)
    FreshBooks.setup(config[:apihost],config[:apikey])
    @cachefile = "cache/"+ cfg[:apikey] + ".yaml"
    if File.exists?(@opt.cachefile)
      @cache = YAML.load_file(@opt.cachefile)
    else
      @cache = OpenStruct.new
      @cache.timesheets =  { }
    end
  end
  def save_cache
    File.open(@cachefile, "w") { |f| f.puts(@cache.to_yaml) }
  end
  def populate_id_cache
    @cache.clients = { }
    @cache.projects = { }
    @cache.tasks = { }
    FreshBooks::Client.list.each do |c|
      @cache.clients[c.client_id] = c.organization
      puts "#{c.client_id} : #{c.organization}"
      @cache.projects[c.client_id]= { }
      FreshBooks::Project.list([['client_id', c.client_id],]).each do |p|
        @cache.projects[c.client_id][p.project_id] = p.name
        puts "  #{p.project_id} : #{p.name}"
        @cache.tasks[c.project_id]= { }
        FreshBooks::Task.list([['project_id', p.project_id],]).each do |t|
          @cache.tasks[c.project_id][t.task_id] = t.name
          puts "    #{t.task_id} : #{t.name}"
        end
      end
    end
    save_cache
  end
  def timesheet_for_client(client_id,from_date,to_date)
    populate_id_cache if @cache.clients.nil?
    if @cache.timesheets.contains? [client_id,from_date,to_date]
      return @cache.timesheets[[client_id,from_date,to_date]]
    end
    weeklyhours=0
    ts={}
    @cache.projects[client_id].each_key do |pid|
      @cache.projects[pid].each do |tid|
        FreshBooks::Time_Entry.list([
                                      ['date_from', from_date],
                                      ['date_to', to_date],
                                      ['task_id',tid],
                                      ['project_id',pid],
                                     ]).each do |e|
          if not ts[e.date]
              ts[e.date] = [[e.hours,p.name,e.notes]]
          else
              ts[e.date] << [e.hours,p.name,e.notes]
          end
        end
      end
    end
    @cache.timesheets[[client_id,from_date,to_date]]=ts
    save_cache
    return ts
  end
end
