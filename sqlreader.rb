#!/usr/bin/env ruby
require 'erb'
require 'yaml'
require 'ostruct'
require 'optparse'
require 'active_record'
require 'lib/freshbooktime/freshbooks'
require 'lib/freshbooktime/models'

class CacheCommandLine
  attr_accessor :opt

  def initialize
    # Set defaults
    @opt = {
      :verbose => false,
      :usecache => false,
      :savecache => false,
      :myconf => File.join(File.dirname(__FILE__),
                          "./conf/myconfig.yml"),
      :displaytype => :text,
      :outfile => nil,
      :username => '',
      :year => Date.today.year,
      :month => Date.today.mon,
      :period => case Date.today.day when 0..15 then 1 else 2 end,
    }
    o = OptionParser.new
    script_name = File.basename($0)
    o.set_summary_indent('   ')
    o.banner = "Usage: #{script_name} COMMAND [OPTIONS]"
    o.define_head 'for CodeCafe'
    o.separator   'COMMAND is one of: push, pull, mail'
    o.separator "OPTIONS are as follows:"
    o.on('--outfile=[OUTFILE]') { |x| @opt[:outfile] = x }
    o.on('--year=[YEAR]'      ) { |x| @opt[:year]    = x.to_i  }
    o.on('--period=[ONEORTWO]',
         "Period (1 or 2)"    ) { |x| @opt[:period]  = x.to_i  }
    o.on('--month=[MONTH]'    ) do |month|
      if Date::MONTHNAMES.include? month
        @opt[:month] = Date::MONTHNAMES.index(month)
      elsif [1,2,3,4,5,6,7,8,9,10,11,12].member? month
        @opt[:month] = month
      else
        puts "Month must be one of:"
        puts Date::MONTHNAMES
      end
    end
    o.on('--config=[CONFIG]'  ) { |x| @opt[:myconf]   = x }
    o.on('--username=USERNAME') { |x| @opt[:username] = x }
    o.on('--display-type=[TYPE]',   :OPTIONAL,
         "Display-Type (text,yaml,html)"
         ) do |x| @opt[:displaytype]   = case x
                                       when 'text'; :text
                                       when 'html'; :html
                                       when 'yaml'; :yaml
                                       else nil
                                       end
    end
    #o.on('--cache-file', String ) { |x| @opt[:cachefile = x }
    o.on('--use-cache')  { @opt[:usecache]  = 1 }
    o.on('--save-cache') { @opt[:savecache] = 1 }
    o.on_tail('-v',  '--verbose')     { @opt[:verbose]   = 1 }
    o.on_tail("-h", "--help", "Show this help message.") { puts o; exit }
    o.parse!(ARGV) #rescue return false
    @optparser = o

    # Command
    if ARGV.length != 1
      puts "At least one and only one COMMAND allowed"
      puts "The remaining arguments were: #{ARGV.inspect}"
      return nil
    end

    @opt[:command] = case ARGV[0]
                   when 'push'; :push
                   when 'pull'; :pull
                   when 'mail'; :mail
                   else
                     puts "COMMAND not valid."
                     return nil
                   end
    # Month

    #load config file
    @opt.update(YAML.load_file(@opt[:myconf]))
    puts @opt.to_yaml if @opt[:verbose]

    if not @opt[:apihost] && @opt[:apikey]
      puts "CONFIG missing :apikey or :apihost"
      puts @opt.to_yaml
      exit
    end

    return @opt
  end

end

class Cache
  attr_accessor :opt, :tsdata
  def initialize
    @opt=CacheCommandLine.new.opt

    FreshBooks.setup(@opt[:apihost],
                     @opt[:apikey])
    ActiveRecord::Base.logger = Logger.new(STDERR)
    ActiveRecord::Base.colorize_logging = true # false
    ActiveRecord::Base.establish_connection(
                                            :adapter => "sqlite3",
                                            :dbfile  => "./cache/db" #:memory:"
                                            )
  end

  def run
    tsdata_gen
    #puts @total
    #puts @week_totals.to_yaml
    #puts @week_sheets.to_yaml
  end


  def list_for_period(type=:twice_monthly)
    case type
      when :weekly ; nil
      when :twice_monthly ; list_for_twice_monthly
      else nil
    end
  end

  def list_for_twice_monthly
    #TODO: week ends on Sat/Sun?

    # set date_end and date_start for period
    if @opt[:period] == 1
      date_start = Date.new(@opt[:year],@opt[:month],1)
      date_end = date_start + 16 #FIXME: make end on option
    elsif @opt[:period] == 2
      date_start = Date.new(@opt[:year],@opt[:month],16)
      # adding 16 days gives us some day next month
      somedaynextmonth = date_start + 16
      nextmonthyear = somedaynextmonth.year
      nextmonth = somedaynextmonth.mon
      # now take the first day of next month and subtract one day
      date_end = Date.new(nextmonthyear,nextmonth,1)-1
    end

    #create outlist of [[startweek1,endweek1][startweek2,endweek2]...]
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

  def pull_from_cache
    # need to pull client_id from config or server( or server cache)
    client_id = 13 #client_config[:catalis][:client_id]
    period_list = list_for_period
    @total=0
    @week_totals={}
    @week_sheets={}
    puts period_list.to_yaml if @opt[:verbose]
    period_list.each do |start,stop|
      weektotal=0
      this_week_sheet={}
      start.upto(stop) { |thisday|
# tt=TimeEntry.find_all_by_staff__id(
#             Staff.find_by_username('chris').staff_id,
#                                    :conditions => {
#                                      :date => Date::civil(2009,12,1) ..
#                                      Date::civil(2009,12,31),}
#                                    )
        Staff.find_by_username(@opt[:username]
                               ).time_entries.find_all_by_date(
                           thisday).each do |e|
          weektotal+=e.hours
          project = Project.find_by_project_id(e.project__id)
          if not this_week_sheet[thisday]
            this_week_sheet[thisday] = [[e.hours,project.name,e.notes]]
          else
            this_week_sheet[thisday] << [e.hours,project.name,e.notes]
          end
        end
      }
      @week_sheets[[start,stop]]=this_week_sheet
      #ts=@fb.timesheet_for_client(client_id,start,stop)
      @week_totals[[start,stop]]=weektotal
      @total += weektotal
    end
    #ts # raw list
    #total # total for period
    #week_totals # dictionary of (weekstart,weekstop) = week_total_hours
    @week_sheets
  end

  def tsdata_gen
    # Generate tsname from day_start day_end
    day_start = list_for_period[0][0]
    day_end   = list_for_period[-1][1]
    tsname = "Timesheet details - "
    tsname += [Date::MONTHNAMES[day_start.month]," ",
               day_start.day,', ',day_start.year].join("")
    tsname += " to "
    tsname += [Date::MONTHNAMES[day_end.month]," ",
               day_end.day,', ',day_end.year].join("")
    weeklist = pull_from_cache
    staff= Staff.find_by_username(@opt[:username])
    @tsdata={
      :name => staff.first_name + ' ' + staff.last_name, # @opt[:name],
      :mycompany => @opt[:company],
      :myphone => staff.business_phone, # @opt[:phone],
      :myemail => staff.email, # @opt[:email],
      :totalhours => @total,
      :weeksheet => @week_sheets,
      :weektotals => @week_totals,
      :timesheet_title => tsname,
      #:customer_html_logo => client_config[:catalis][:html_logo]
    }
    @tsdata
  end
end

class Output
#  def get_binding
#    binding
#  end
  def render_timesheet(type=:yaml)
    tsdata = @tsdata
    if type == :yaml
      rdata = @tsdata.to_yaml
    elsif type == :text
      tmplfile = "templates/timesheet_tmpl.rtxt"
      template = File.open(tmplfile).read
      message = ERB.new(template, 0, "%<>")
      rdata = message.result(binding)
      #rdata = message.result
    elsif type == :html
      tmplfile = "templates/timesheet_tmpl.rhtml"
      template = File.open(tmplfile).read
      message = ERB.new(template, 0, "%<>")#, @tsdata)
      rdata = message.result(binding)
      # rdata = "Render HTML and save NOT FINISHED"
    else
      # "Unknown type #{type}"
      rdata = nil
    end
    rdata
  end

  def save_timesheet(filename, type=:yaml)
    puts "Looking for #{filename}"
    return false if File.exist?(filename)
    puts "Rendering data of type #{type}"
    rdata = render_timesheet(type)
    out = File.new(filename, "w+")
    out.puts rdata
    true
  end

  def display_timesheet(type=:text)
    puts render_timesheet(type)
  end

  def export
    # need to pull customer_name from config or server( or server cache)
    customer_name = "catalis" #client_config[:catalis][:name]

    puts "Working on timesheet for #{customer_name}:"

    if @opt[:outfile].nil?
      display_timesheet(@opt[:displaytype])
    else
      ext = @opt[:outfile].match(/\.(.*)$/)[1]
      type = case ext
             when 'yml'; :yaml
             when 'html'; :html
             when 'txt','text'; :text
             else nil
             end
      if save_timesheet(@opt[:outfile], type)
        puts "Time sheet saved to #{@opt[:outfile]} as type #{type.inspect}"
        puts " because of #{ext}"
      else
        puts "Could not save data to file! Does it already exist?"
      end
    end
    #generate template
  end

  def initialize(opt,tsdata)
    @opt=opt
    @tsdata=tsdata
  end
end
x=Cache.new
x.run
o=Output.new(x.opt,x.tsdata)
o.export
