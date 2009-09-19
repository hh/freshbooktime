#!/usr/bin/env ruby

require 'rubygems'
require 'action_mailer'
require 'mime/types'
require 'yaml'
require 'lib/smtp_tls'
require 'lib/action_mailer_tls'

mc = YAML.load_file("mailconf.yml")

ActionMailer::Base.smtp_settings = mc[:smtp_settings]
ActionMailer::Base.template_root = 'templates'
#  { :address  =>  '10.209.3.26', :domain => '3dlabs.com'}

class Mailer < ActionMailer::Base
  def message (from_a, to, sub, b, apath=nil)
    
    from from_a
    recipients to
    subject sub
    body b

    unless apath.nil?
      file = File.basename(apath)
      mime_type = MIME::Types.of(file).first
      content_type = mime_type ? mime_type.content_type : 'application/binary'
      attachment (content_type) do |a|
        a.body = File.read(apath)
        a.filename = file
        a.transfer_encoding = 'quoted-printable' if content_type =~ /^text\//
      end
    end
  end
  def candidate_for_layout?(x=nil)
    false
  end
  def find_template
    false
  end
end

Mailer.deliver_message(mc[:from], mc[:to], mc[:subject], mc[:body], ARGV[0])
