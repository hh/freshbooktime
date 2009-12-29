# --- !ruby/struct:FreshBooks::Client
# client_id: 13
# first_name: aoeu
# last_name: asdf
# organization: acompany
# email: them
# username: aname
# password:
# work_phone: 555-555-5555
# home_phone: ""
# mobile: 555-555-5555
# fax: ""
# notes: |-
#   Multiline notes here
#   The can be long
# p_street1: 5000 An Ave
# p_street2: ""
# p_city: Town
# p_state: Province
# p_country: United States
# p_code: "12345"
# s_street1: ""
# s_street2: ""
# s_city: ""
# s_state: ""
# s_country: ""
# s_code: ""
# url: https://mycomp.freshbooks.com/view/randomdigits
./script/generate scaffold Client \
    first_name:string \
    last_name:string \
    organization:string \
    email:string \
    username:string \
    password:string \
    work_phone:string \
    home_phone:string \
    mobile:string \
    fax:string \
    notes:text \
    p_street1:string \
    p_street2:string \
    p_city:string \
    p_state:string \
    p_country:string \
    p_code:string \
    url:string

# --- !ruby/struct:FreshBooks::Project
# project_id: 10
# client_id: 0
# name: something
# bill_method: staff-rate
# rate: 0.0
# description: bill-me
# tasks: []

./script/generate scaffold Project \
    client_id:integer \
    name:string \
    bill_method:string \
    rate:decimal \
    description:string \
    tasks:integer


# --- !ruby/struct:FreshBooks::Task
# task_id: 20
# name: Administrative
# billable: "0"
# rate: 0.0
# description: ""

./script/generate scaffold Task \
    name:string \
    billable:boolean \
    rate:decimal \
    description:string

# --- !ruby/struct:FreshBooks::Staff
# staff_id: 1
# username: admin
# first_name: my
# last_name: admin
# email: freshbooks@mycompany.com
# business_phone: ""
# mobile_phone: ""
# rate: "100"
# last_login: 2009-12-29 11:13:00
# number_of_logins: "2000"
# signup_date: 2008-04-13 18:26:30
# street1: ""
# street2: ""
# city: ""
# state: ""
# country: ""
# code: ""

./script/generate scaffold Staff \
    username:string \
    first_name:string \
    last_name:string \
    email:string \
    business_phone:string \
    mobile_phone:string \
    rate:string \
    last_login:string \
    number_of_logins:integer \
    signup_date:string \
    street1:string \
    street2:string \
    city:string \
    state:string \
    country:string \
    code:string

# --- !ruby/struct:FreshBooks::Time_Entry
# time_entry_id: 88
# project_id: 14
# task_id: 4
# hours: 1.5
# notes:  Research
# date: "2009-07-08"

./script/generate scaffold TimeEntry \
    project_id:integer \
    task_id:integer \
    hours:decimal \
    notes:string \
    date:string
