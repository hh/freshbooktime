require "freshtimesheet"
require "erb"
require 'yaml'

def render_timesheet(tsdata, type=:yaml)
  if type == :yaml
    rdata = tsdata.to_yaml
  elsif type == :text
    tmplfile = "timesheet_tmpl.rtxt"
    template = File.open(tmplfile)
    message = ERB.new(template, 0, "%<>")
    rdata = message.result
  elsif type == :html
    # tmplfile = "timesheet_tmpl.rhtml"
    # template = File.open(tmplfile)
    # message = ERB.new(template, 0, "%<>")
    # rdata = message.result
    rdata = "Render HTML and save NOT FINISHED"
  else
    # "Unknown type #{type}"
    rdata = nil
  end
  rdata
end

def save_timesheet(data, filename, type=:yaml)
  return false if File.exist?(filename)
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

apiconfig = YAML.load_file(File.join(File.dirname(__FILE__), "apiconfig.yml"))
client_config = YAML.load_file(File.join(File.dirname(__FILE__), "client_config.yml"))
myconfig = YAML.load_file(File.join(File.dirname(__FILE__), "myconfig.yml"))
timeperiods = YAML.load_file(File.join(File.dirname(__FILE__), "timeperiods.yml"))

t=FreshTime.new(apiconfig)

customer_name = client_config[:catalis][:name]
client_id     = client_config[:catalis][:client_id]

# puts "Working on timesheet for #{customer_name}:"
# total=0
# weeklist={}
# timeperiods.each do |start,stop|
#   ts=t.timesheet_for_client(client_id,start,stop)
#   total+=ts[:weekly_total]
#   weeklist[[start,stop]]=ts
# end
# tsdata={
#     :name => myconfig[:name],
#     :totalhours => total,
#     :weeksheets => weeklist
# }

tsdata = YAML.load_file(File.join(File.dirname(__FILE__), "test-taylor_ts_data.yml"))

if outfile.nil?
  display_timesheet(tsdata)
else
  ext = outfile.match(/\.(.*)$/)[0]
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

  if save_timesheet(data, outfile, type)
    puts "Time sheet saved to #{fn}"
  end
end

#generate template

