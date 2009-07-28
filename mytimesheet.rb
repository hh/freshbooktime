require "freshtimesheet"
require 'yaml'

apiconfig = YAML.load_file(File.join(File.dirname(__FILE__), "apiconfig.yml"))
client_config = YAML.load_file(File.join(File.dirname(__FILE__), "client_config.yml"))
myconfig = YAML.load_file(File.join(File.dirname(__FILE__), "myconfig.yml"))

t=FreshTime.new(apiconfig)

customer_name = client_config[:catalis][:name]
client_id     = client_config[:catalis][:client_id]

puts "Timesheet for #{customer_name}:"
total=0
weeklist={}
[ ['2009-07-01','2009-07-04'],
  ['2009-07-05','2009-07-11'],
  ['2009-07-12','2009-07-15']].each do |start,stop|
  ts=t.timesheet_for_client(client_id,start,stop)
  total+=ts[:weekly_total]
  weeklist[[start,stop]]=ts
end
namespace={
    :name => myconfig[:name],
    :totalhours => total,
    :weeksheets => weeklist
}

#generate template

