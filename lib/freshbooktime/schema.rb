require 'rubygems'
require 'active_record'

module FreshTimeCacheSchema
  def FreshTimeCacheSchema.create
    ActiveRecord::Schema.define do
      create_table :clients do |t|
        t.integer  "client_id"
        t.string   "first_name"
        t.string   "last_name"
        t.string   "organization"
        t.string   "email"
        t.string   "username"
        t.string   "password"
        t.string   "work_phone"
        t.string   "home_phone"
        t.string   "mobile"
        t.string   "fax"
        t.text     "notes"
        t.string   "p_street1"
        t.string   "p_street2"
        t.string   "p_city"
        t.string   "p_state"
        t.string   "p_country"
        t.string   "p_code"
        t.string   "s_street1"
        t.string   "s_street2"
        t.string   "s_city"
        t.string   "s_state"
        t.string   "s_country"
        t.string   "s_code"
        t.string   "url"
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      create_table :projects do |t|
        t.integer  "project_id"
        t.integer  "client_id"
        t.integer  "client__id"
        t.string   "name"
        t.string   "bill_method"
        t.decimal  "rate"
        t.string   "description"
        t.integer  "tasks"
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      create_table :tasks do |t|
        t.integer  "task_id"
        t.integer  "project_id"
        t.integer  "project__id"
        t.string   "name"
        t.boolean  "billable"
        t.decimal  "rate"
        t.string   "description"
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      create_table :time_entries do |t|
        t.integer  "time_entry_id"
        t.integer  "project__id"
        t.integer  "task__id"
        t.integer  "staff__id"
        t.decimal  "hours"
        t.string   "notes"
        t.date     "date"
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      create_table :staffs do |t|
        t.integer  "staff_id"
        t.string   "username"
        t.string   "first_name"
        t.string   "last_name"
        t.string   "email"
        t.string   "business_phone"
        t.string   "mobile_phone"
        t.string   "rate"
        t.string   "last_login"
        t.integer  "number_of_logins"
        t.string   "signup_date"
        t.string   "street1"
        t.string   "street2"
        t.string   "city"
        t.string   "state"
        t.string   "country"
        t.string   "code"
        t.datetime "created_at"
        t.datetime "updated_at"
      end
    end
  end
end
