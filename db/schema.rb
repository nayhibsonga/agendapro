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

ActiveRecord::Schema.define(version: 20131209204752) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "billing_logs", force: true do |t|
    t.float    "payment"
    t.float    "amount"
    t.date     "next_payment"
    t.integer  "company_id"
    t.integer  "plan_id"
    t.integer  "transaction_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bookings", force: true do |t|
    t.datetime "start"
    t.datetime "end"
    t.text     "notes"
    t.integer  "staff_id"
    t.integer  "user_id"
    t.integer  "location_id"
    t.integer  "status_id"
    t.integer  "promotion_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", force: true do |t|
    t.string   "name"
    t.string   "web_address"
    t.string   "logo"
    t.float    "pay_due"
    t.integer  "economic_sector_id"
    t.integer  "plan_id"
    t.integer  "payment_status_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "company_settings", force: true do |t|
    t.text     "signature"
    t.boolean  "email"
    t.boolean  "sms"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "days", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "districts", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "economic_sectors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "location_times", force: true do |t|
    t.time     "open"
    t.time     "close"
    t.integer  "location_id"
    t.integer  "day_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.string   "adress"
    t.string   "phone"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "country_id"
    t.integer  "region_id"
    t.integer  "city_id"
    t.integer  "district_id"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_statuses", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plan_logs", force: true do |t|
    t.integer  "prev_plan_id"
    t.integer  "new_plan_id"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", force: true do |t|
    t.string   "name"
    t.integer  "locations"
    t.integer  "staffs"
    t.boolean  "custom"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "promotions", force: true do |t|
    t.string   "code"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "regions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_staffs", force: true do |t|
    t.integer  "service_id"
    t.integer  "staff_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "services", force: true do |t|
    t.string   "name"
    t.float    "price"
    t.integer  "duration"
    t.text     "description"
    t.boolean  "group_service"
    t.integer  "capacity"
    t.boolean  "waiting_list"
    t.integer  "company_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staff_times", force: true do |t|
    t.time     "open"
    t.time     "close"
    t.integer  "staff_id"
    t.integer  "day_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staffs", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.string   "user_name"
    t.string   "password"
    t.integer  "location_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transaction_types", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.string   "user_name"
    t.string   "password"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
