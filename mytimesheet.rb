require "freshtimesheet"
require "erb"
require 'yaml'

# FIXME: make cache an option as well as env var
USECACHE = (ENV['USECACHE'].nil? or ENV['USECACHE'] == '0') ? false : true
SAVECACHE = ((ENV['SAVECACHE'].nil? or ENV['SAVECACHE'] == '0' and 
             (ENV['UPDATECACHE'].nil? or ENV['UPDATECACHE'] == '0')) ? false : true
CACHEFILE="last_timesheet.yml"
DISPLAYTYPE = :text

def save_cache(tsdata)
  rdata = render_timesheet(tsdata, :yaml)
  out = File.new(CACHEFILE, "w+")
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
    message = ERB.new(template, 0, "%<>")
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


#################


### FIXME: use optparse

if ARGV.length == 1 or (ARGV.length > 1 and ARGV[0] != "-o") or ARGV[0] == "-h" or ARGV[0] == "-help"
  puts "usage: $0 [-o <filename>]"
  exit 0
elsif ARGV.length >=2
  outfile=ARGV[1]
else
  outfile=nil
end

client_config = YAML.load_file(File.join(File.dirname(__FILE__), "conf/client_config.yml"))
myconfig = YAML.load_file(File.join(File.dirname(__FILE__), "conf/myconfig.yml"))
tsconfig = YAML.load_file(File.join(File.dirname(__FILE__), "conf/timesheet_config.yml"))

t=FreshTime.new(:apihost => myconfig[:apihost], :apikey => myconfig[:apikey])

customer_name = client_config[:catalis][:name]
client_id     = client_config[:catalis][:client_id]

puts "Working on timesheet for #{customer_name}:"

if USECACHE
  puts "Loading from cache"
  tsdata = YAML.load_file(File.join(File.dirname(__FILE__), CACHEFILE))
else
  puts "Pulling data from web"
  total=0
  weeklist={}
  tsconfig[:time_periods].each do |start,stop|
    ts=t.timesheet_for_client(client_id,start,stop)
    total+=ts[:weekly_total]
    weeklist[[start,stop]]=ts
  end
  tsdata={
      :name => myconfig[:name],
      :mycompany => myconfig[:company],
      :myphone => myconfig[:phone],
      :myemail => myconfig[:email],
      :totalhours => total,
      :weeksheets => weeklist,
      :timesheet_title => tsconfig[:title],
      :customer_html_logo => client_config[:catalis][:html_logo]
  }
end


if outfile.nil?
  display_timesheet(tsdata, DISPLAYTYPE)
else
  ext = outfile.match(/\.(.*)$/)[1]
  case ext
  when 'yml'
    type = :yaml
  when 'html'
    type = :html
  when 'txt','text'
    type = :text
  else
    type = nil
  end

  if save_timesheet(tsdata, outfile, type)
    puts "Time sheet saved to #{outfile}"
  else
    puts "Could not save data to file! Does it already exist?"
  end
end

if SAVECACHE
  save_cache(tsdata)
end
#generate template

