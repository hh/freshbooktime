#!/usr/bin/env ruby

require 'rubygems'
require 'action_mailer'
require 'inline_attachment'
require 'mime/types'
require 'yaml'
require 'lib/smtp_tls'
require 'lib/action_mailer_tls'
require 'pp'

MAILCONF = 'conf/mailconf.yml'
#MAILCONF = 'conf/mailconf-chris.yml'
TSCONF = 'conf/timesheet_config.yml'

mc = YAML.load_file(MAILCONF)
tsc = YAML.load_file(TSCONF)

ActionMailer::Base.smtp_settings = mc[:smtp_settings]
ActionMailer::Base.template_root = 'templates'

class Mailer < ActionMailer::Base
  def message (from_a, to, sub, b, *att)
    
    from from_a
    recipients to
    subject sub
    body b

    att.flatten!

    att.each do |apath|
      puts "trying to attach file #{apath}"
      file = File.basename(apath)
      mime_type = MIME::Types.of(file).first
      #content_type = mime_type ? mime_type.content_type : 'application/binary'
      content_type = mime_type ? mime_type.content_type : 'plain/text'
      puts "ct: #{content_type}"
      inline_attachment :content_type => content_type,
        :body => File.read(apath),
        :filename => file,
        :cid => ""
        #transfer_encoding => 'quoted-printable' if content_type =~ /^text\//
      #end
    end
  end
end

body = mc[:body] || tsc[:title]
subject = "#{mc[:subject]} #{tsc[:title]}"
Mailer.deliver_message(mc[:from], mc[:to], subject, body, ARGV)


