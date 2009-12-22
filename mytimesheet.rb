#!/usr/bin/env ruby
require "freshtimesheet"
require "erb"
require 'yaml'
require 'optparse'
require 'date'
require 'ostruct'

class MyTimeSheet
  VERSION = "0.0.10"

  attr_accessor :opt, :cfg, :optparser, :tsdata

  def initialize
    # Set defaults
    @opt = OpenStruct.new
    @opt.verbose = false
    @opt.myconf = 'conf/myconfig.yml'
    @opt.usecache = false
    @opt.savecache = false
    @opt.cachefile = 'last_timesheet.yml'
    @opt.displaytype = :text
    @opt.outfile = nil
    @opt.basedir = File.dirname(__FILE__)
    @opt.year = Date.today.year
    @opt.month = Date.today.mon
    @opt.period = case Date.today.day when 0..15 then 1 else 2 end
  end

  def run
    if parsed_options? && arguments_valid?
      puts "Start at #{DateTime.now}\n\n" if @opt.verbose
      puts @opt.to_yaml if @opt.verbose # [Optional]
      process_options
      process_command
      puts "\nFinished at #{DateTime.now}" if @opt.verbose
    else
      puts @optparser
    end
  end

  #protected

  def update_cache
    @cache = OpenStruct.new
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
    puts @cache.to_yaml
  end

  def parsed_options?
    o = OptionParser.new
    script_name = File.basename($0)
    o.set_summary_indent('   ')
    o.banner = "Usage: #{script_name} [OPTIONS]"
    o.define_head 'Pull current period timesheet'
    o.separator   ''
    o.separator "Eventually pull and push, but for now just futzing"
    o.on('--outfile=[OUTFILE]', :OPTIONAL,
         "Outfile"
         ) { |x| @opt.outfile = x }
    o.on('--year=[YEAR]',    :OPTIONAL,
         "Year"
         ) { |x| @opt.year    = x.to_i  }
    o.on('--period=[ONEORTWO]',  :OPTIONAL,
         "Period (1 or 2)"
         ) { |x| @opt.period  = x.to_i  }
    o.on('--month=[MONTH]',   :OPTIONAL,
         "Month"
         ) { |x| @opt.month   = x }
    o.on('--config=[CONFIG]',   :OPTIONAL,
         "Config File"
         ) { |x| @opt.myconf   = x }
    o.on('--display-type=[TYPE]',   :OPTIONAL,
         "Display-Type (text,yaml,html)"
         ) do |x| @opt.displaytype   = case x
                                      when 'text'; :text
                                      when 'html'; :html
                                      when 'yaml'; :yaml
                                      else nil
                                      end
    end
    o.on('--cache-file', String ) { |x| @opt.cachefile = x }
    o.on('--use-cache')  { @opt.usecache  = 1 }
    o.on('--save-cache') { @opt.savecache = 1 }
    o.on('-v',  '--verbose')     { @opt.verbose   = 1 }
    o.on_tail("-h", "--help", "Show this help message.") { puts o; exit }
    o.parse!(ARGV) #rescue return false
    @optparser = o
    true
  end

  def process_options
    @cfg = YAML.load_file(File.join(@opt.basedir, @opt.myconf))
    @fb = FreshTime.new(:apihost => @cfg[:apihost],
                         :apikey => @cfg[:apikey])
    @opt.cachefile = "cache/"+[@cfg[:email],@opt.year,@opt.month,@opt.period].join("-") + ".yaml"
    puts @cfg.to_yaml if @opt.verbose
  end

  def arguments_valid?
    # client_config hardcoded for now
    # @o.client_config = YAML.load_file(
    #   File.join(basedir,"conf/client_config.yml"))
    if Date::MONTHNAMES.include? @opt.month
      @opt.month = Date::MONTHNAMES.index(@opt.month)
    elsif [1,2,3,4,5,6,7,8,9,10,11,12].member? @opt.month
      nil
    else
      puts "Month must be one of:"
      puts Date::MONTHNAMES
      exit
    end
  end

  def pull_from_web
    # need to pull client_id from config or server( or server cache)
    client_id = 13 #client_config[:catalis][:client_id]
    puts "Pulling data from web"
    period_list = list_for_period
    day_start = period_list[0][0]
    day_end   = period_list[-1][1]
    @ts=@fb.timesheet_for_client(client_id,day_start,day_end)
  end
  def foo
      nil
  end
    puts ts.inspect if @opt.verbose
    total=0
    week_totals={}
    week_sheets={}
    puts period_list.to_yaml if @opt.verbose
    period_list.each do |start,stop|
      weektotal=0
      start.upto(stop) { |thisday|
        day thisday.to_s
        ts[day].each do |entry|
          (hours,name,notes)=entry.split
          weektotal+=hours
          if not week_sheets[day]
            week_sheets[day] = [[hours,name,notes]]
          else
            week_sheets[day] << [hours,name,notes]
          end
        end
      }

      #ts=@fb.timesheet_for_client(client_id,start,stop)
      week_totals[[start,stop]]=weektotal
      total += weektotal
  end
    ts # raw list
    total # total for period
    week_totals # dictionary of (weekstart,weekstop) = week_total_hours

    # Generate tsname from day_start day_end
    tsname = "Timesheet details - "
    tsname += [Date::MONTHNAMES[day_start.month]," ",
               day_start.day,', ',day_start.year].join("")
    tsname += " to "
    tsname += [Date::MONTHNAMES[day_end.month]," ",
               day_end.day,', ',day_end.year].join("")

    @tsdata={
      :name => @cfg[:name],
      :mycompany => @cfg[:company],
      :myphone => @cfg[:phone],
      :myemail => @cfg[:email],
      :totalhours => total,
      :weeksheets => weeklist,
      :timesheet_title => tsname,
      #:customer_html_logo => client_config[:catalis][:html_logo]
    }
    @tsdata
  end

  def process_command
    # need to pull customer_name from config or server( or server cache)
    customer_name = "catalis" #client_config[:catalis][:name]

    puts "Working on timesheet for #{customer_name}:"

    if @opt.usecache
      puts "Loading from cache"
      tsdata = YAML.load_file(File.join(@opt.basedir, @opt.cachefile))
    else
      tsdata = pull_from_web
      save_cache(tsdata) if @opt.savecache
    end

    if @opt.outfile.nil?
      display_timesheet(tsdata, @opt.displaytype)
    else
      ext = @opt.outfile.match(/\.(.*)$/)[1]
      type = case ext
             when 'yml'; :yaml
             when 'html'; :html
             when 'txt','text'; :text
             else nil
             end
      if save_timesheet(tsdata, @opt.outfile, type)
        puts "Time sheet saved to #{outfile}"
      else
        puts "Could not save data to file! Does it already exist?"
      end
    end
    #generate template
  end

  def save_cache(tsdata)
    rdata = render_timesheet(tsdata, :yaml)
    out = File.new(@opt.cachefile, "w+")
    out.puts rdata
    true
  end

  def render_timesheet(tsdata, type=:yaml)
    if type == :yaml
      rdata = tsdata.to_yaml
    elsif type == :text
      tmplfile = "templates/timesheet_tmpl.rtxt"
      template = File.open(tmplfile)
      #template = File.open(tmplfile).read.gsub(/^\s+/, '')
      message = ERB.new(template, 0, "%<>")
      rdata = message.result
    elsif type == :html
      tmplfile = "templates/timesheet_tmpl.rhtml"
      template = File.open(tmplfile)
      message = ERB.new(template, 0, "%<>", tsdata)
      rdata = message.result
      # rdata = "Render HTML and save NOT FINISHED"
    else
      # "Unknown type #{type}"
      rdata = nil
    end
    rdata
  end

  def save_timesheet(data, filename, type=:yaml)
    puts "Looking for #{filename}"
    return false if File.exist?(filename)
    puts "Rendering data of type #{type}"
    rdata = render_timesheet(data, type)
    out = File.new(filename, "w+")
    out.puts rdata
    true
  end

  def display_timesheet(data, type=:text)
    puts render_timesheet(data, type)
  end


  def list_for_period
    if @opt.period == 1
      date_start = Date.new(@opt.year,@opt.month,1)
      date_end = date_start + 16
    elsif @opt.period == 2
      date_start = Date.new(@opt.year,@opt.month,16)
      # adding 16 days gives us some day next month
      somedaynextmonth = date_start + 16
      nextmonthyear = somedaynextmonth.year
      nextmonth = somedaynextmonth.mon
      # now take the first day of next month and subtract one day
      date_end = Date.new(nextmonthyear,nextmonth,1)-1
    end
    week1end = date_start + 6 - date_start.wday #saturday that week
    outlist = [[date_start,week1end],]
    startweek = nil
    (week1end + 1).upto(date_end-1) do |day|
      startweek = day if day.cwday == 7 #Sunday
      outlist << [startweek,day] if day.cwday == 6 #Saturday
    end
    outlist << [startweek,date_end]
    outlist
  end

end

MyTimeSheet.new.run
