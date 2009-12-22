##
## fb_id_cach.rb
## Login : <chris@mbp.austin.rr.com>
## Started on  Mon Dec 21 15:18:28 2009 Chris McClimans
## $Id$
##
## Copyright (C) 2009 Chris McClimans
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
##

require 'freshbooks'
require "erb"
require 'ostruct'

class FreshTimeCache
  attr_accessor :cache

  def initialize(config)
    FreshBooks.setup(config[:apihost],config[:apikey])
  end
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
end

FreshTimeCache.new
