require 'freshbooks'
require 'yaml'
$config = YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))



# It's string but the order _IS_ important... maybe that's a rubyism... or just bad code
# Found project_id and task_id from Project.list and Task.list below
# Returns the time_entry_id

#FreshBooks::Time_Entry.new(time_entry_id=0,project_id=10, task_id=7, hours=4, notes="More Poop from Script",date="2009-06-26").create
#FreshBooks::Time_Entry.new(0,10,7,4,"More Poop from Script","2009-06-26").create

#clients = FreshBooks::Client.list
#client = clients[0]
#client.first_name = 'Suzy'
#client.update

#invoice = FreshBooks::Invoice.get(4)
#invoice.lines[0].quantity += 1
#invoice.update

#item = FreshBooks::Item.new
#item.name = 'A sample item'
#item.create

# Listing of each important thing:

class FreshTime
  def initialize
    FreshBooks.setup($config['apihost'],$config['apikey'])
    FreshBooks::Client.list.each do |c|
      puts "#{c.client_id} : #{c.organization}"
      FreshBooks::Project.list([['client_id', c.client_id],]).each do |p|
        puts "  #{p.project_id} : #{p.name}"
        FreshBooks::Task.list([['project_id', p.project_id],]).each do |t|
          puts "    #{t.task_id} : #{t.name}"
        end
      end
    end
  end
end

FreshTime.new

class TimeSheet
  def initialize
    client_id = 13 # A specific client
    from_date = '2009-07-01'
    to_date =  '2009-07-15'
    FreshBooks.setup($config['apihost'],$config['apikey'])
    FreshBooks::Project.list([['client_id', client_id],]).each do |p|
      FreshBooks::Task.list([['project_id', p.project_id],]).each do |t|
        FreshBooks::Time_Entry.list([
                                      ['date_from', from_date],
                                      ['date_to', to_date],
                                      ['task_id',t.task_id],
                                      ['project_id',p.project_id],
                                     ]).each do |e|
          puts "#{e.date}, #{e.hours}: #{p.name}, #{e.notes}"
        end
      end
    end
  end
end

TimeSheet.new


