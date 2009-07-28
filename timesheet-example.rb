require "erb"
require "testdata"

template = %q{
  Timesheet for <% namespace[:name] %>
  <% namespace[:weeksheets].each do |range,timesheet| %>
  <% week_start = range[0] %><% week_end = range[1] %><% weekly_total = timesheet[:weekly_total] %>

    <%= week_start %> - <%= week_end %> Start!
  <% timesheet[:weekly_timesheet].each do |date,entries| %>
  <% entries.each do |hours,project,note| %>
    <%= [date,hours,project,note].inspect %>
  <% end %>
  <% end %>
    <%= week_start %> - <%= week_end %> Total: <%= weekly_total %>
  <% end %>

  Total:  <%= namespace[:totalhours] %>
  }.gsub(/^  /, '')

message = ERB.new(template, 0, "%<>")
puts message.result
