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

ActiveRecord::Schema.define(version: 20131223151845) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "billing_logs", force: true do |t|
    t.float    "payment",             null: false
    t.float    "amount",              null: false
    t.date     "next_payment",        null: false
    t.integer  "company_id",          null: false
    t.integer  "plan_id",             null: false
    t.integer  "transaction_type_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bookings", force: true do |t|
    t.datetime "start",               null: false
    t.datetime "end",                 null: false
    t.text     "notes"
    t.integer  "service_provider_id", null: false
    t.integer  "user_id",             null: false
    t.integer  "service_id",          null: false
    t.integer  "location_id",         null: false
    t.integer  "status_id",           null: false
    t.integer  "promotion_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", force: true do |t|
    t.string   "name",       null: false
    t.integer  "region_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", force: true do |t|
    t.string   "name",                null: false
    t.string   "web_address",         null: false
    t.string   "logo"
    t.float    "pay_due"
    t.integer  "economic_sector_id",  null: false
    t.integer  "plan_id",             null: false
    t.integer  "payment_status_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.text     "cancellation_policy"
  end

  create_table "company_settings", force: true do |t|
    t.text     "signature"
    t.boolean  "email",      default: false
    t.boolean  "sms",        default: false
    t.integer  "company_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "districts", force: true do |t|
    t.string   "name",       null: false
    t.integer  "city_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "economic_sectors", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "location_times", force: true do |t|
    t.time     "open",        null: false
    t.time     "close",       null: false
    t.integer  "location_id", null: false
    t.integer  "day_id",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.string   "name",        null: false
    t.string   "address",     null: false
    t.string   "phone",       null: false
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "district_id", null: false
    t.integer  "company_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  create_table "plans", force: true do |t|
    t.string   "name",                       null: false
    t.integer  "locations",                  null: false
    t.integer  "staffs",                     null: false
    t.boolean  "custom",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "price",      default: 0.0,   null: false
    t.boolean  "special",    default: false
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

  create_table "provider_times", force: true do |t|
    t.time     "open",                null: false
    t.time     "close",               null: false
    t.integer  "service_provider_id", null: false
    t.integer  "day_id",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "regions", force: true do |t|
    t.string   "name",       null: false
    t.integer  "country_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name",        null: false
    t.text     "description", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_providers", force: true do |t|
    t.integer  "location_id"
    t.integer  "user_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id",  null: false
  end

  create_table "service_staffs", force: true do |t|
    t.integer  "service_id",          null: false
    t.integer  "service_provider_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "services", force: true do |t|
    t.string   "name",                          null: false
    t.float    "price",                         null: false
    t.integer  "duration",                      null: false
    t.text     "description"
    t.boolean  "group_service", default: false
    t.integer  "capacity"
    t.boolean  "waiting_list",  default: false
    t.integer  "company_id",                    null: false
    t.integer  "tag_id",                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", force: true do |t|
    t.string   "name",        null: false
    t.text     "description", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transaction_types", force: true do |t|
    t.string   "name",        null: false
    t.text     "description", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "first_name",                          null: false
    t.string   "last_name",                           null: false
    t.string   "phone",                               null: false
    t.integer  "role_id",                             null: false
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "user_name",              default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["user_name"], name: "index_users_on_user_name", unique: true, using: :btree

end
