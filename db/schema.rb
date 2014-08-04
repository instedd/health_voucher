# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140804171103) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.string   "object_class"
    t.integer  "object_id"
    t.text     "description"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "activities", ["created_at"], :name => "index_activities_on_created_at"
  add_index "activities", ["object_class"], :name => "index_activities_on_object_class"
  add_index "activities", ["object_id"], :name => "index_activities_on_object_id"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "authorizations", :force => true do |t|
    t.integer  "card_id"
    t.integer  "provider_id"
    t.integer  "service_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "message_id"
  end

  add_index "authorizations", ["card_id"], :name => "index_authorizations_on_card_id"
  add_index "authorizations", ["message_id"], :name => "index_authorizations_on_message_id"
  add_index "authorizations", ["provider_id"], :name => "index_authorizations_on_provider_id"
  add_index "authorizations", ["service_id"], :name => "index_authorizations_on_service_id"

  create_table "batches", :force => true do |t|
    t.string   "name"
    t.string   "initial_serial_number"
    t.integer  "quantity"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "cards", :force => true do |t|
    t.string   "serial_number"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "patient_id"
    t.integer  "site_id"
    t.date     "validity"
    t.string   "status"
    t.integer  "batch_id"
    t.string   "check_digit"
    t.date     "expiration"
  end

  add_index "cards", ["batch_id"], :name => "index_cards_on_batch_id"
  add_index "cards", ["patient_id"], :name => "index_cards_on_pacient_id"
  add_index "cards", ["serial_number"], :name => "index_cards_on_serial_number"
  add_index "cards", ["site_id"], :name => "index_cards_on_site_id"

  create_table "clinic_services", :force => true do |t|
    t.integer  "clinic_id"
    t.integer  "service_id"
    t.boolean  "enabled"
    t.decimal  "cost",       :precision => 10, :scale => 2
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "clinic_services", ["clinic_id"], :name => "index_clinic_services_on_clinic_id"
  add_index "clinic_services", ["service_id"], :name => "index_clinic_services_on_service_id"

  create_table "clinics", :force => true do |t|
    t.string   "name"
    t.integer  "site_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "clinics", ["site_id"], :name => "index_clinics_on_site_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "mentors", :force => true do |t|
    t.string   "name"
    t.integer  "site_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "mentors", ["site_id"], :name => "index_mentors_on_site_id"

  create_table "messages", :force => true do |t|
    t.string   "from"
    t.string   "body"
    t.string   "message_type"
    t.string   "status"
    t.string   "response"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "patients", :force => true do |t|
    t.string   "agep_id"
    t.integer  "mentor_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "current_card_id"
  end

  add_index "patients", ["current_card_id"], :name => "index_pacients_on_current_card_id"
  add_index "patients", ["mentor_id"], :name => "index_pacients_on_mentor_id"

  create_table "providers", :force => true do |t|
    t.string   "name"
    t.integer  "clinic_id"
    t.string   "code"
    t.boolean  "enabled"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "providers", ["clinic_id"], :name => "index_providers_on_clinic_id"

  create_table "services", :force => true do |t|
    t.string   "service_type"
    t.string   "description"
    t.string   "short_description"
    t.string   "code"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.boolean  "training"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  add_index "sites", ["user_id"], :name => "index_sites_on_user_id"

  create_table "statements", :force => true do |t|
    t.integer  "clinic_id"
    t.date     "until"
    t.string   "status"
    t.decimal  "total",      :precision => 10, :scale => 2
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "statements", ["clinic_id"], :name => "index_statements_on_clinic_id"

  create_table "transactions", :force => true do |t|
    t.integer  "voucher_id"
    t.integer  "authorization_id"
    t.integer  "statement_id"
    t.string   "status"
    t.text     "comment"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.integer  "message_id"
    t.decimal  "amount",           :precision => 10, :scale => 2
  end

  add_index "transactions", ["authorization_id"], :name => "index_transactions_on_authorization_id"
  add_index "transactions", ["message_id"], :name => "index_transactions_on_message_id"
  add_index "transactions", ["statement_id"], :name => "index_transactions_on_statement_id"
  add_index "transactions", ["voucher_id"], :name => "index_transactions_on_voucher_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",       :null => false
    t.string   "encrypted_password",     :default => "",       :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.string   "role",                   :default => "normal"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "vouchers", :force => true do |t|
    t.string   "code"
    t.integer  "card_id"
    t.string   "service_type"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.boolean  "used",         :default => false
  end

  add_index "vouchers", ["card_id"], :name => "index_vouchers_on_card_id"
  add_index "vouchers", ["code"], :name => "index_vouchers_on_code"

end
