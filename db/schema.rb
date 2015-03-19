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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150319184051) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "fuzzystrmatch"
  enable_extension "unaccent"

  create_table "banks", force: true do |t|
    t.integer  "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "billing_infos", force: true do |t|
    t.string   "name"
    t.string   "rut"
    t.string   "address"
    t.string   "sector"
    t.string   "email"
    t.string   "phone"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     default: false
    t.string   "contact"
    t.boolean  "accept",     default: false
  end

  add_index "billing_infos", ["company_id"], name: "index_billing_infos_on_company_id", using: :btree

  create_table "billing_logs", force: true do |t|
    t.float    "payment",             null: false
    t.float    "amount",              null: false
    t.integer  "company_id",          null: false
    t.integer  "plan_id",             null: false
    t.integer  "transaction_type_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "trx_id"
  end

  add_index "billing_logs", ["company_id"], name: "index_billing_logs_on_company_id", using: :btree
  add_index "billing_logs", ["plan_id"], name: "index_billing_logs_on_plan_id", using: :btree
  add_index "billing_logs", ["transaction_type_id"], name: "index_billing_logs_on_transaction_type_id", using: :btree

  create_table "billing_records", force: true do |t|
    t.integer  "company_id"
    t.float    "amount"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "transaction_type_id"
  end

  create_table "booking_histories", force: true do |t|
    t.integer  "booking_id"
    t.string   "action"
    t.integer  "staff_code_id"
    t.datetime "start"
    t.integer  "status_id"
    t.integer  "service_id"
    t.integer  "service_provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "booking_histories", ["booking_id"], name: "index_booking_histories_on_booking_id", using: :btree
  add_index "booking_histories", ["service_id"], name: "index_booking_histories_on_service_id", using: :btree
  add_index "booking_histories", ["service_provider_id"], name: "index_booking_histories_on_service_provider_id", using: :btree
  add_index "booking_histories", ["staff_code_id"], name: "index_booking_histories_on_staff_code_id", using: :btree
  add_index "booking_histories", ["status_id"], name: "index_booking_histories_on_status_id", using: :btree
  add_index "booking_histories", ["user_id"], name: "index_booking_histories_on_user_id", using: :btree

  create_table "bookings", force: true do |t|
    t.datetime "start",                               null: false
    t.datetime "end",                                 null: false
    t.text     "notes",               default: ""
    t.integer  "service_provider_id",                 null: false
    t.integer  "user_id"
    t.integer  "service_id",                          null: false
    t.integer  "location_id",                         null: false
    t.integer  "status_id",                           null: false
    t.integer  "promotion_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "company_comment",     default: ""
    t.boolean  "web_origin",          default: false
    t.boolean  "send_mail",           default: true
    t.integer  "client_id"
    t.float    "price",               default: 0.0
    t.boolean  "provider_lock",       default: false
    t.integer  "max_changes",         default: 2
    t.integer  "deal_id"
    t.boolean  "payed",               default: false
    t.string   "trx_id",              default: ""
    t.string   "token",               default: ""
    t.integer  "booking_group"
    t.integer  "payed_booking_id"
  end

  add_index "bookings", ["client_id"], name: "index_bookings_on_client_id", using: :btree
  add_index "bookings", ["deal_id"], name: "index_bookings_on_deal_id", using: :btree
  add_index "bookings", ["location_id"], name: "index_bookings_on_location_id", using: :btree
  add_index "bookings", ["promotion_id"], name: "index_bookings_on_promotion_id", using: :btree
  add_index "bookings", ["service_id"], name: "index_bookings_on_service_id", using: :btree
  add_index "bookings", ["service_provider_id"], name: "index_bookings_on_service_provider_id", using: :btree
  add_index "bookings", ["status_id"], name: "index_bookings_on_status_id", using: :btree
  add_index "bookings", ["user_id"], name: "index_bookings_on_user_id", using: :btree

  create_table "cities", force: true do |t|
    t.string   "name",       null: false
    t.integer  "region_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cities", ["region_id"], name: "index_cities_on_region_id", using: :btree

  create_table "client_comments", force: true do |t|
    t.integer  "client_id"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_comments", ["client_id"], name: "index_client_comments_on_client_id", using: :btree

  create_table "clients", force: true do |t|
    t.integer  "company_id"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "address"
    t.string   "district"
    t.string   "city"
    t.integer  "age"
    t.integer  "gender"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identification_number"
    t.boolean  "can_book",              default: true
    t.integer  "birth_day"
    t.integer  "birth_month"
    t.integer  "birth_year"
  end

  add_index "clients", ["company_id"], name: "index_clients_on_company_id", using: :btree

  create_table "companies", force: true do |t|
    t.string   "name",                               null: false
    t.string   "web_address",                        null: false
    t.string   "logo"
    t.float    "months_active_left",  default: 0.0
    t.integer  "plan_id",                            null: false
    t.integer  "payment_status_id",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.text     "cancellation_policy"
    t.boolean  "active",              default: true
    t.float    "due_amount",          default: 0.0
    t.date     "due_date"
    t.boolean  "owned",               default: true
  end

  add_index "companies", ["payment_status_id"], name: "index_companies_on_payment_status_id", using: :btree
  add_index "companies", ["plan_id"], name: "index_companies_on_plan_id", using: :btree

  create_table "company_cron_logs", force: true do |t|
    t.integer  "company_id"
    t.integer  "action_ref"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "company_economic_sectors", force: true do |t|
    t.integer  "company_id"
    t.integer  "economic_sector_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "company_economic_sectors", ["company_id"], name: "index_company_economic_sectors_on_company_id", using: :btree
  add_index "company_economic_sectors", ["economic_sector_id"], name: "index_company_economic_sectors_on_economic_sector_id", using: :btree

  create_table "company_from_emails", force: true do |t|
    t.string   "email",                      null: false
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "confirmed",  default: false
  end

  add_index "company_from_emails", ["company_id"], name: "index_company_from_emails_on_company_id", using: :btree

  create_table "company_settings", force: true do |t|
    t.text     "signature"
    t.boolean  "email",                       default: false
    t.boolean  "sms",                         default: false
    t.integer  "company_id",                                                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "before_booking",              default: 3,                     null: false
    t.integer  "after_booking",               default: 3,                     null: false
    t.integer  "before_edit_booking",         default: 3
    t.boolean  "activate_search",             default: false
    t.boolean  "activate_workflow",           default: true
    t.boolean  "client_exclusive",            default: false
    t.integer  "provider_preference"
    t.integer  "calendar_duration",           default: 15
    t.boolean  "extended_schedule_bool",      default: false,                 null: false
    t.time     "extended_min_hour",           default: '2000-01-01 09:00:00', null: false
    t.time     "extended_max_hour",           default: '2000-01-01 20:00:00', null: false
    t.boolean  "schedule_overcapacity",       default: true,                  null: false
    t.boolean  "provider_overcapacity",       default: true,                  null: false
    t.boolean  "resource_overcapacity",       default: true,                  null: false
    t.integer  "booking_confirmation_time",   default: 1,                     null: false
    t.boolean  "booking_history",             default: false
    t.boolean  "staff_code",                  default: false
    t.integer  "booking_configuration_email", default: 0
    t.integer  "max_changes",                 default: 2
    t.boolean  "deal_activate",               default: false
    t.string   "deal_name"
    t.boolean  "deal_overcharge",             default: true
    t.integer  "monthly_mails",               default: 0,                     null: false
    t.boolean  "deal_exclusive",              default: false
    t.integer  "deal_quantity",               default: 0
    t.integer  "deal_constraint_option",      default: 0
    t.integer  "deal_constraint_quantity",    default: 0
    t.boolean  "deal_identification_number",  default: false
    t.boolean  "deal_required",               default: false,                 null: false
    t.boolean  "allows_online_payment",       default: false
    t.string   "account_number",              default: ""
    t.string   "company_rut",                 default: ""
    t.string   "account_name",                default: ""
    t.integer  "account_type",                default: 3
    t.integer  "bank_id"
    t.string   "locations",                   default: "Lugares",             null: false
    t.string   "services",                    default: "Servicios",           null: false
    t.string   "staff",                       default: "Staff",               null: false
    t.boolean  "online_payment_capable",      default: false
    t.boolean  "allows_optimization",         default: true
  end

  add_index "company_settings", ["company_id"], name: "index_company_settings_on_company_id", using: :btree

  create_table "countries", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "days", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deals", force: true do |t|
    t.string   "code",                               null: false
    t.integer  "quantity",                           null: false
    t.boolean  "active",              default: true
    t.integer  "constraint_option",                  null: false
    t.integer  "constraint_quantity",                null: false
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deals", ["company_id"], name: "index_deals_on_company_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "dictionaries", force: true do |t|
    t.string   "name",       null: false
    t.integer  "tag_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "districts", force: true do |t|
    t.string   "name",       null: false
    t.integer  "city_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "districts", ["city_id"], name: "index_districts_on_city_id", using: :btree

  create_table "economic_sectors", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "economic_sectors_dictionaries", force: true do |t|
    t.string   "name"
    t.integer  "economic_sector_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "economic_sectors_dictionaries", ["economic_sector_id"], name: "index_economic_sectors_dictionaries_on_economic_sector_id", using: :btree

  create_table "facebook_pages", force: true do |t|
    t.integer  "company_id"
    t.string   "facebook_page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "facebook_pages", ["company_id"], name: "index_facebook_pages_on_company_id", using: :btree

  create_table "location_outcall_districts", force: true do |t|
    t.integer  "location_id"
    t.integer  "district_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "location_outcall_districts", ["district_id"], name: "index_location_outcall_districts_on_district_id", using: :btree
  add_index "location_outcall_districts", ["location_id"], name: "index_location_outcall_districts_on_location_id", using: :btree

  create_table "location_times", force: true do |t|
    t.time     "open",        null: false
    t.time     "close",       null: false
    t.integer  "location_id"
    t.integer  "day_id",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "location_times", ["day_id"], name: "index_location_times_on_day_id", using: :btree
  add_index "location_times", ["location_id"], name: "index_location_times_on_location_id", using: :btree

  create_table "locations", force: true do |t|
    t.string   "name",                                        null: false
    t.string   "address",                                     null: false
    t.string   "phone",                                       null: false
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "district_id",                                 null: false
    t.integer  "company_id",                                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                      default: true
    t.integer  "order",                       default: 0
    t.boolean  "outcall",                     default: false
    t.string   "email",                       default: ""
    t.boolean  "notification",                default: false
    t.integer  "booking_configuration_email", default: 0
    t.string   "second_address"
    t.boolean  "online_booking",              default: true
  end

  add_index "locations", ["company_id"], name: "index_locations_on_company_id", using: :btree
  add_index "locations", ["district_id"], name: "index_locations_on_district_id", using: :btree

  create_table "numeric_parameters", force: true do |t|
    t.string   "name"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "online_cancelation_policies", force: true do |t|
    t.boolean  "cancelable",         default: true
    t.boolean  "modifiable",         default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cancel_max",         default: 24
    t.integer  "modification_max",   default: 1
    t.integer  "min_hours",          default: 12
    t.integer  "modification_unit",  default: 1
    t.integer  "cancel_unit",        default: 2
    t.integer  "company_setting_id"
  end

  create_table "payed_bookings", force: true do |t|
    t.integer  "punto_pagos_confirmation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "transfer_complete",           default: false
    t.boolean  "canceled",                    default: false
    t.boolean  "cancel_complete",             default: false
    t.integer  "payment_account_id"
  end

  create_table "payment_accounts", force: true do |t|
    t.string   "name"
    t.string   "rut"
    t.string   "number"
    t.float    "amount"
    t.integer  "bank_code"
    t.integer  "currency",       default: 0
    t.integer  "origin",         default: 1
    t.integer  "destiny",        default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "status",         default: false
    t.integer  "account_type",   default: 3
    t.integer  "company_id"
    t.float    "company_amount", default: 0.0
    t.float    "gain_amount",    default: 0.0
  end

  create_table "payment_statuses", force: true do |t|
    t.string   "name",        null: false
    t.text     "description", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plan_logs", force: true do |t|
    t.integer  "prev_plan_id", null: false
    t.integer  "new_plan_id",  null: false
    t.integer  "company_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "trx_id"
  end

  add_index "plan_logs", ["company_id"], name: "index_plan_logs_on_company_id", using: :btree

  create_table "plans", force: true do |t|
    t.string   "name",                              null: false
    t.integer  "locations",                         null: false
    t.integer  "service_providers",                 null: false
    t.boolean  "custom",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "price",             default: 0.0,   null: false
    t.boolean  "special",           default: false
    t.integer  "monthly_mails",     default: 5000,  null: false
  end

  create_table "promotions", force: true do |t|
    t.string   "code",       null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "provider_breaks", force: true do |t|
    t.datetime "start"
    t.datetime "end"
    t.integer  "service_provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "break_group_id"
  end

  add_index "provider_breaks", ["service_provider_id"], name: "index_provider_breaks_on_service_provider_id", using: :btree

  create_table "provider_times", force: true do |t|
    t.time     "open",                null: false
    t.time     "close",               null: false
    t.integer  "service_provider_id"
    t.integer  "day_id",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "provider_times", ["day_id"], name: "index_provider_times_on_day_id", using: :btree
  add_index "provider_times", ["service_provider_id"], name: "index_provider_times_on_service_provider_id", using: :btree

  create_table "punto_pagos_confirmations", force: true do |t|
    t.string   "token"
    t.string   "trx_id"
    t.string   "payment_method"
    t.float    "amount"
    t.date     "approvement_date"
    t.string   "card_number"
    t.string   "dues_number"
    t.string   "dues_type"
    t.string   "dues_amount"
    t.date     "first_due_date"
    t.string   "operation_number"
    t.string   "authorization_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "response"
  end

  create_table "punto_pagos_creations", force: true do |t|
    t.string   "trx_id",         null: false
    t.string   "payment_method", null: false
    t.float    "amount",         null: false
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "regions", force: true do |t|
    t.string   "name",       null: false
    t.integer  "country_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "regions", ["country_id"], name: "index_regions_on_country_id", using: :btree

  create_table "resource_categories", force: true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resource_categories", ["company_id"], name: "index_resource_categories_on_company_id", using: :btree

  create_table "resource_locations", force: true do |t|
    t.integer  "resource_id"
    t.integer  "location_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resource_locations", ["location_id"], name: "index_resource_locations_on_location_id", using: :btree
  add_index "resource_locations", ["resource_id"], name: "index_resource_locations_on_resource_id", using: :btree

  create_table "resources", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resource_category_id"
    t.integer  "company_id"
  end

  add_index "resources", ["company_id"], name: "index_resources_on_company_id", using: :btree
  add_index "resources", ["resource_category_id"], name: "index_resources_on_resource_category_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name",        null: false
    t.text     "description", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_categories", force: true do |t|
    t.string   "name",                   null: false
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order",      default: 0
  end

  add_index "service_categories", ["company_id"], name: "index_service_categories_on_company_id", using: :btree

  create_table "service_payment_logs", force: true do |t|
    t.string   "token"
    t.string   "trx_id"
    t.integer  "service_id",          null: false
    t.integer  "company_id",          null: false
    t.decimal  "amount",              null: false
    t.integer  "transaction_type_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "service_payment_logs", ["transaction_type_id"], name: "index_service_payment_logs_on_transaction_type_id", using: :btree

  create_table "service_providers", force: true do |t|
    t.integer  "location_id"
    t.integer  "company_id",                                 null: false
    t.string   "notification_email"
    t.string   "public_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                      default: true
    t.integer  "order",                       default: 0
    t.integer  "block_length",                default: 30
    t.integer  "booking_configuration_email", default: 0
    t.decimal  "comission_value",             default: 0.0,  null: false
    t.integer  "comission_option",            default: 0,    null: false
    t.boolean  "online_booking",              default: true
  end

  add_index "service_providers", ["company_id"], name: "index_service_providers_on_company_id", using: :btree
  add_index "service_providers", ["location_id"], name: "index_service_providers_on_location_id", using: :btree

  create_table "service_resources", force: true do |t|
    t.integer  "service_id"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "service_resources", ["resource_id"], name: "index_service_resources_on_resource_id", using: :btree
  add_index "service_resources", ["service_id"], name: "index_service_resources_on_service_id", using: :btree

  create_table "service_staffs", force: true do |t|
    t.integer  "service_id",          null: false
    t.integer  "service_provider_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "service_staffs", ["service_id"], name: "index_service_staffs_on_service_id", using: :btree
  add_index "service_staffs", ["service_provider_id"], name: "index_service_staffs_on_service_provider_id", using: :btree

  create_table "service_tags", force: true do |t|
    t.integer  "service_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "service_tags", ["service_id"], name: "index_service_tags_on_service_id", using: :btree
  add_index "service_tags", ["tag_id"], name: "index_service_tags_on_tag_id", using: :btree

  create_table "services", force: true do |t|
    t.string   "name",                                null: false
    t.float    "price",               default: 0.0
    t.integer  "duration",                            null: false
    t.text     "description"
    t.boolean  "group_service",       default: false
    t.integer  "capacity"
    t.boolean  "waiting_list",        default: false
    t.integer  "company_id",                          null: false
    t.integer  "service_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",              default: true
    t.boolean  "show_price",          default: true
    t.integer  "order",               default: 0
    t.boolean  "outcall",             default: false
    t.boolean  "has_discount",        default: false
    t.float    "discount",            default: 0.0
    t.boolean  "online_payable",      default: false
    t.decimal  "comission_value",     default: 0.0,   null: false
    t.integer  "comission_option",    default: 0,     null: false
    t.boolean  "online_booking",      default: true
  end

  add_index "services", ["company_id"], name: "index_services_on_company_id", using: :btree
  add_index "services", ["service_category_id"], name: "index_services_on_service_category_id", using: :btree

  create_table "staff_codes", force: true do |t|
    t.string   "staff"
    t.string   "code"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "staff_codes", ["company_id"], name: "index_staff_codes_on_company_id", using: :btree

  create_table "statuses", force: true do |t|
    t.string   "name",        null: false
    t.text     "description", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.string   "name",               null: false
    t.integer  "economic_sector_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["economic_sector_id"], name: "index_tags_on_economic_sector_id", using: :btree

  create_table "time_units", force: true do |t|
    t.string   "unit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transaction_types", force: true do |t|
    t.string   "name",        null: false
    t.text     "description", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_locations", force: true do |t|
    t.integer  "user_id"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_locations", ["location_id"], name: "index_user_locations_on_location_id", using: :btree
  add_index "user_locations", ["user_id"], name: "index_user_locations_on_user_id", using: :btree

  create_table "user_providers", force: true do |t|
    t.integer  "user_id"
    t.integer  "service_provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_providers", ["service_provider_id"], name: "index_user_providers_on_service_provider_id", using: :btree
  add_index "user_providers", ["user_id"], name: "index_user_providers_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.integer  "role_id",                             null: false
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["company_id"], name: "index_users_on_company_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree

end
