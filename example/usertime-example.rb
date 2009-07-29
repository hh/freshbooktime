require "freshtimesheet"
require 'yaml'
$config = YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))

CLIENT_X=13
t=FreshTime.new($config)

puts "Timesheet for Client_X:"
total=0
weeklist={}
[ ['2009-07-01','2009-07-04'],
  ['2009-07-05','2009-07-11'],
  ['2009-07-12','2009-07-15']].each do |start,stop|
  ts=t.timesheet_for_client(CLIENT_X,start,stop)
  total+=ts[:weekly_total]
  weeklist[[start,stop]]=ts
end
namespace={
    :name => 'Johnny Be Good',
    :totalhours => total,
    :weeksheets => weeklist
}

#generate template

