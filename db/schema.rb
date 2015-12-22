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

ActiveRecord::Schema.define(version: 20151216135454) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
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

  create_table "billing_wire_transfers", force: true do |t|
    t.datetime "payment_date",       default: '2015-12-10 14:46:35'
    t.float    "amount",             default: 0.0
    t.string   "receipt_number",     default: ""
    t.string   "account_name",       default: ""
    t.string   "account_bank",       default: ""
    t.string   "account_number",     default: ""
    t.boolean  "approved",           default: false
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "change_plan",        default: false
    t.integer  "new_plan"
    t.float    "change_plan_amount", default: 0.0
    t.float    "new_plan_amount",    default: 0.0
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
    t.text     "notes",               default: ""
    t.text     "company_comment",     default: ""
  end

  add_index "booking_histories", ["booking_id"], name: "index_booking_histories_on_booking_id", using: :btree
  add_index "booking_histories", ["service_id"], name: "index_booking_histories_on_service_id", using: :btree
  add_index "booking_histories", ["service_provider_id"], name: "index_booking_histories_on_service_provider_id", using: :btree
  add_index "booking_histories", ["staff_code_id"], name: "index_booking_histories_on_staff_code_id", using: :btree
  add_index "booking_histories", ["status_id"], name: "index_booking_histories_on_status_id", using: :btree
  add_index "booking_histories", ["user_id"], name: "index_booking_histories_on_user_id", using: :btree

  create_table "bookings", force: true do |t|
    t.datetime "start",                                  null: false
    t.datetime "end",                                    null: false
    t.text     "notes",                  default: ""
    t.integer  "service_provider_id",                    null: false
    t.integer  "user_id"
    t.integer  "service_id",                             null: false
    t.integer  "location_id",                            null: false
    t.integer  "status_id",                              null: false
    t.integer  "promotion_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "company_comment",        default: ""
    t.boolean  "web_origin",             default: false
    t.boolean  "send_mail",              default: true
    t.integer  "client_id"
    t.float    "price",                  default: 0.0
    t.boolean  "provider_lock",          default: false
    t.boolean  "payed",                  default: false
    t.string   "trx_id",                 default: ""
    t.integer  "max_changes",            default: 2
    t.string   "token",                  default: ""
    t.integer  "deal_id"
    t.integer  "booking_group"
    t.integer  "payed_booking_id"
    t.boolean  "is_session",             default: false
    t.integer  "session_booking_id"
    t.boolean  "user_session_confirmed", default: false
    t.boolean  "is_session_booked",      default: false
    t.integer  "service_promo_id"
    t.integer  "payment_id"
    t.float    "discount",               default: 0.0
    t.boolean  "is_booked",              default: true
    t.integer  "reminder_group"
    t.float    "list_price",             default: 0.0
    t.integer  "receipt_id"
    t.boolean  "payed_state",            default: false
    t.boolean  "marketplace_origin",     default: false
    t.integer  "treatment_promo_id"
    t.integer  "last_minute_promo_id"
  end

  add_index "bookings", ["client_id"], name: "index_bookings_on_client_id", using: :btree
  add_index "bookings", ["deal_id"], name: "index_bookings_on_deal_id", using: :btree
  add_index "bookings", ["location_id"], name: "index_bookings_on_location_id", using: :btree
  add_index "bookings", ["payment_id"], name: "index_bookings_on_payment_id", using: :btree
  add_index "bookings", ["promotion_id"], name: "index_bookings_on_promotion_id", using: :btree
  add_index "bookings", ["service_id"], name: "index_bookings_on_service_id", using: :btree
  add_index "bookings", ["service_provider_id"], name: "index_bookings_on_service_provider_id", using: :btree
  add_index "bookings", ["start"], name: "index_bookings_on_start", using: :btree
  add_index "bookings", ["status_id"], name: "index_bookings_on_status_id", using: :btree
  add_index "bookings", ["user_id"], name: "index_bookings_on_user_id", using: :btree

  create_table "cashiers", force: true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "code"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.string   "email",                 default: ""
    t.string   "first_name",            default: ""
    t.string   "last_name",             default: ""
    t.string   "phone",                 default: ""
    t.string   "address",               default: ""
    t.string   "district",              default: ""
    t.string   "city",                  default: ""
    t.integer  "age"
    t.integer  "gender",                default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identification_number", default: ""
    t.boolean  "can_book",              default: true
    t.integer  "birth_day"
    t.integer  "birth_month"
    t.integer  "birth_year"
    t.string   "record",                default: ""
    t.string   "second_phone",          default: ""
  end

  add_index "clients", ["company_id"], name: "index_clients_on_company_id", using: :btree

  create_table "companies", force: true do |t|
    t.string   "name",                                null: false
    t.string   "web_address",                         null: false
    t.string   "logo"
    t.float    "months_active_left",  default: 0.0
    t.integer  "plan_id",                             null: false
    t.integer  "payment_status_id",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description",         default: ""
    t.text     "cancellation_policy", default: ""
    t.boolean  "active",              default: true
    t.float    "due_amount",          default: 0.0
    t.date     "due_date"
    t.boolean  "owned",               default: true
    t.boolean  "show_in_home",        default: false
    t.integer  "country_id"
    t.boolean  "activate_i18n",       default: false
    t.integer  "sales_user_id"
    t.integer  "trial_months_left",   default: 0
  end

  add_index "companies", ["country_id"], name: "index_companies_on_country_id", using: :btree
  add_index "companies", ["payment_status_id"], name: "index_companies_on_payment_status_id", using: :btree
  add_index "companies", ["plan_id"], name: "index_companies_on_plan_id", using: :btree

  create_table "company_countries", force: true do |t|
    t.integer  "company_id"
    t.integer  "country_id"
    t.string   "web_address", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "company_countries", ["company_id"], name: "index_company_countries_on_company_id", using: :btree
  add_index "company_countries", ["country_id"], name: "index_company_countries_on_country_id", using: :btree

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

  create_table "company_payment_methods", force: true do |t|
    t.string   "name",                           null: false
    t.integer  "company_id",                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",          default: true
    t.boolean  "number_required", default: true
  end

  add_index "company_payment_methods", ["company_id"], name: "index_company_payment_methods_on_company_id", using: :btree

  create_table "company_plan_settings", force: true do |t|
    t.integer  "company_id"
    t.integer  "locations",         default: 1
    t.integer  "service_providers", default: 1
    t.integer  "monthly_mails",     default: 0
    t.boolean  "has_custom_price",  default: false
    t.float    "custom_price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.integer  "max_changes",                 default: 2
    t.boolean  "booking_history",             default: true
    t.boolean  "staff_code",                  default: false
    t.integer  "monthly_mails",               default: 0,                     null: false
    t.boolean  "allows_online_payment",       default: false
    t.string   "account_number",              default: ""
    t.string   "company_rut",                 default: ""
    t.string   "account_name",                default: ""
    t.integer  "account_type",                default: 3
    t.integer  "bank_id"
    t.boolean  "deal_activate",               default: false
    t.string   "deal_name",                   default: ""
    t.boolean  "deal_overcharge",             default: true
    t.boolean  "deal_exclusive",              default: false
    t.integer  "deal_quantity",               default: 0
    t.integer  "deal_constraint_option",      default: 0
    t.integer  "deal_constraint_quantity",    default: 0
    t.boolean  "deal_identification_number",  default: false
    t.boolean  "deal_required",               default: false,                 null: false
    t.boolean  "online_payment_capable",      default: false
    t.boolean  "allows_optimization",         default: true
    t.boolean  "activate_notes",              default: true,                  null: false
    t.boolean  "receipt_required",            default: true
    t.float    "online_payment_commission",   default: 5.0
    t.float    "promo_commission",            default: 10.0
    t.boolean  "promo_offerer_capable",       default: false
    t.boolean  "can_edit",                    default: true
    t.boolean  "can_cancel",                  default: true
    t.boolean  "use_identification_number",   default: false
    t.boolean  "payment_client_required",     default: true
    t.boolean  "show_cashes",                 default: false
    t.string   "preset_notes"
    t.boolean  "editable_payment_prices",     default: true
    t.boolean  "mandatory_mock_booking_info", default: false
  end

  add_index "company_settings", ["company_id"], name: "index_company_settings_on_company_id", using: :btree

  create_table "countries", force: true do |t|
    t.string   "name",                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale",            default: ""
    t.string   "flag_photo",        default: ""
    t.string   "currency_code",     default: ""
    t.float    "latitude"
    t.float    "longitude"
    t.string   "formatted_address", default: ""
    t.string   "domain",            default: ""
    t.float    "sales_tax",         default: 0.0, null: false
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
    t.string   "name",                                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_in_home",            default: true
    t.boolean  "show_in_company",         default: true
    t.string   "mobile_preview",          default: ""
    t.boolean  "marketplace",             default: false
    t.integer  "marketplace_category_id"
  end

  add_index "economic_sectors", ["marketplace_category_id"], name: "index_economic_sectors_on_marketplace_category_id", using: :btree

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

  create_table "fake_payments", force: true do |t|
    t.integer  "company_id"
    t.float    "amount"
    t.integer  "receipt_type_id"
    t.string   "receipt_number"
    t.integer  "payment_method_id"
    t.string   "payment_method_number"
    t.integer  "payment_method_type_id"
    t.integer  "installments"
    t.boolean  "payed"
    t.date     "payment_date"
    t.integer  "bank_id"
    t.integer  "company_payment_method_id"
    t.float    "discount"
    t.text     "notes"
    t.integer  "location_id"
    t.integer  "client_id"
    t.float    "bookings_amount"
    t.float    "bookings_discount"
    t.float    "products_amount"
    t.float    "products_discount"
    t.integer  "products_quantity"
    t.integer  "bookings_quantity"
    t.integer  "quantity"
    t.float    "sessions_amount"
    t.float    "sessions_discount"
    t.integer  "sessions_quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favorites", force: true do |t|
    t.integer  "user_id"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorites", ["location_id"], name: "index_favorites_on_location_id", using: :btree
  add_index "favorites", ["user_id"], name: "index_favorites_on_user_id", using: :btree

  create_table "internal_sales", force: true do |t|
    t.integer  "location_id"
    t.integer  "cashier_id"
    t.integer  "service_provider_id"
    t.integer  "product_id"
    t.integer  "quantity",            default: 1
    t.float    "list_price",          default: 0.0
    t.float    "price",               default: 0.0
    t.float    "discount",            default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "date",                default: '2015-11-18 15:55:51'
    t.integer  "user_id"
  end

  create_table "last_minute_promo_locations", force: true do |t|
    t.integer  "last_minute_promo_id"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "last_minute_promos", force: true do |t|
    t.integer  "discount",   default: 0
    t.integer  "hours",      default: 0
    t.integer  "service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "location_outcall_districts", force: true do |t|
    t.integer  "location_id"
    t.integer  "district_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "location_outcall_districts", ["district_id"], name: "index_location_outcall_districts_on_district_id", using: :btree
  add_index "location_outcall_districts", ["location_id"], name: "index_location_outcall_districts_on_location_id", using: :btree

  create_table "location_products", force: true do |t|
    t.integer  "product_id"
    t.integer  "location_id",                null: false
    t.integer  "stock",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stock_limit"
    t.boolean  "alert_flag",  default: true
  end

  add_index "location_products", ["location_id"], name: "index_location_products_on_location_id", using: :btree
  add_index "location_products", ["product_id"], name: "index_location_products_on_product_id", using: :btree

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
    t.string   "name",                           null: false
    t.string   "address",                        null: false
    t.string   "phone",                          null: false
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "district_id",                    null: false
    t.integer  "company_id",                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",         default: true
    t.integer  "order",          default: 0
    t.boolean  "outcall",        default: false
    t.string   "email",          default: ""
    t.string   "second_address", default: ""
    t.boolean  "online_booking", default: true
    t.string   "image1"
    t.string   "image2"
    t.string   "image3"
  end

  add_index "locations", ["company_id"], name: "index_locations_on_company_id", using: :btree
  add_index "locations", ["district_id"], name: "index_locations_on_district_id", using: :btree

  create_table "mailing_lists", force: true do |t|
    t.string   "first_name",     default: ""
    t.string   "last_name",      default: ""
    t.string   "email",          default: ""
    t.string   "phone",          default: ""
    t.boolean  "mailing_option", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "marketplace_categories", force: true do |t|
    t.string   "name",                default: "",    null: false
    t.boolean  "show_in_marketplace", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mock_bookings", force: true do |t|
    t.integer  "client_id"
    t.integer  "service_id"
    t.integer  "service_provider_id"
    t.float    "price"
    t.float    "discount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payment_id"
    t.integer  "receipt_id"
    t.float    "list_price",          default: 0.0
  end

  create_table "notification_emails", force: true do |t|
    t.integer  "company_id"
    t.string   "email",                         null: false
    t.integer  "receptor_type", default: 0
    t.boolean  "summary",       default: true
    t.boolean  "new",           default: false
    t.boolean  "modified",      default: false
    t.boolean  "confirmed",     default: false
    t.boolean  "canceled",      default: false
    t.boolean  "new_web",       default: false
    t.boolean  "modified_web",  default: false
    t.boolean  "confirmed_web", default: false
    t.boolean  "canceled_web",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notification_emails", ["company_id"], name: "index_notification_emails_on_company_id", using: :btree

  create_table "notification_locations", force: true do |t|
    t.integer  "location_id"
    t.integer  "notification_email_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notification_locations", ["location_id"], name: "index_notification_locations_on_location_id", using: :btree
  add_index "notification_locations", ["notification_email_id"], name: "index_notification_locations_on_notification_email_id", using: :btree

  create_table "notification_providers", force: true do |t|
    t.integer  "service_provider_id"
    t.integer  "notification_email_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notification_providers", ["notification_email_id"], name: "index_notification_providers_on_notification_email_id", using: :btree
  add_index "notification_providers", ["service_provider_id"], name: "index_notification_providers_on_service_provider_id", using: :btree

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

  create_table "pay_u_creations", force: true do |t|
    t.string   "trx_id",         null: false
    t.string   "payment_method", null: false
    t.float    "amount",         null: false
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pay_u_notifications", force: true do |t|
    t.string   "merchant_id"
    t.string   "state_pol"
    t.string   "risk"
    t.string   "response_code_pol"
    t.string   "reference_sale"
    t.string   "reference_pol"
    t.string   "sign"
    t.string   "extra1"
    t.string   "extra2"
    t.string   "payment_method"
    t.string   "payment_method_type"
    t.string   "installments_number"
    t.string   "value"
    t.string   "tax"
    t.string   "additional_value"
    t.string   "transaction_date"
    t.string   "currency"
    t.string   "email_buyer"
    t.string   "cus"
    t.string   "pse_bank"
    t.string   "test"
    t.string   "description"
    t.string   "billing_address"
    t.string   "shipping_address"
    t.string   "phone"
    t.string   "office_phone"
    t.string   "account_number_ach"
    t.string   "account_type_ach"
    t.string   "administrative_fee"
    t.string   "administrative_fee_base"
    t.string   "administrative_fee_tax"
    t.string   "airline_code"
    t.string   "attempts"
    t.string   "authorization_code"
    t.string   "bank_id"
    t.string   "billing_city"
    t.string   "billing_country"
    t.string   "commision_pol"
    t.string   "commision_pol_currency"
    t.string   "customer_number"
    t.string   "date"
    t.string   "error_code_bank"
    t.string   "error_message_bank"
    t.string   "exchange_rate"
    t.string   "ip"
    t.string   "nickname_buyer"
    t.string   "nickname_seller"
    t.string   "payment_method_id"
    t.string   "payment_request_state"
    t.string   "pseReference1"
    t.string   "pseReference2"
    t.string   "pseReference3"
    t.string   "response_message_pol"
    t.string   "shipping_city"
    t.string   "shipping_country"
    t.string   "transaction_bank_id"
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cc_number"
    t.string   "cc_holder"
    t.string   "bank_referenced_name"
    t.string   "payment_method_name"
    t.string   "antifraudMerchantId"
  end

  create_table "pay_u_responses", force: true do |t|
    t.string   "merchantId"
    t.string   "transactionState"
    t.string   "risk"
    t.string   "polResponseCode"
    t.string   "referenceCode"
    t.string   "reference_pol"
    t.string   "signature"
    t.string   "polPaymentMethod"
    t.string   "polPaymentMethodType"
    t.string   "installmentsNumber"
    t.string   "TX_VALUE"
    t.string   "TX_TAX"
    t.string   "buyerEmail"
    t.string   "processingDate"
    t.string   "currency"
    t.string   "cus"
    t.string   "pseBank"
    t.string   "lng"
    t.string   "description"
    t.string   "lapResponseCode"
    t.string   "lapPaymentMethod"
    t.string   "lapPaymentMethodType"
    t.string   "lapTransactionState"
    t.string   "message"
    t.string   "extra1"
    t.string   "extra2"
    t.string   "extra3"
    t.string   "authorizationCode"
    t.string   "merchant_address"
    t.string   "merchant_name"
    t.string   "merchant_url"
    t.string   "orderLanguage"
    t.string   "pseCycle"
    t.string   "pseReference1"
    t.string   "pseReference2"
    t.string   "pseReference3"
    t.string   "telephone"
    t.string   "transactionId"
    t.string   "trazabilityCode"
    t.string   "TX_ADMINISTRATIVE_FEE"
    t.string   "TX_TAX_"
    t.string   "ADMINISTRATIVE_FEE"
    t.string   "TX_TAX_ADMINISTRATIVE"
    t.string   "_FEE_RETURN_BASE"
    t.string   "action_code_description"
    t.string   "cc_holder"
    t.string   "cc_number"
    t.string   "processing_date_time"
    t.string   "request_number"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "payment_histories", force: true do |t|
    t.date     "payment_date"
    t.float    "amount",            default: 0.0
    t.float    "discount",          default: 0.0
    t.integer  "payment_method_id"
    t.integer  "user_id"
    t.text     "notes",             default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_histories", ["payment_method_id"], name: "index_payment_histories_on_payment_method_id", using: :btree
  add_index "payment_histories", ["user_id"], name: "index_payment_histories_on_user_id", using: :btree

  create_table "payment_method_settings", force: true do |t|
    t.integer  "company_setting_id"
    t.integer  "payment_method_id"
    t.boolean  "active",             default: true
    t.boolean  "number_required",    default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_method_settings", ["company_setting_id"], name: "index_payment_method_settings_on_company_setting_id", using: :btree
  add_index "payment_method_settings", ["payment_method_id"], name: "index_payment_method_settings_on_payment_method_id", using: :btree

  create_table "payment_method_types", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_methods", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_products", force: true do |t|
    t.integer  "payment_id"
    t.integer  "product_id",                null: false
    t.float    "price",       default: 0.0
    t.float    "discount",    default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quantity",    default: 1,   null: false
    t.integer  "seller_id"
    t.integer  "seller_type"
    t.integer  "receipt_id"
    t.float    "list_price",  default: 0.0
  end

  add_index "payment_products", ["payment_id"], name: "index_payment_products_on_payment_id", using: :btree
  add_index "payment_products", ["product_id"], name: "index_payment_products_on_product_id", using: :btree

  create_table "payment_statuses", force: true do |t|
    t.string   "name",        null: false
    t.text     "description", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_transactions", force: true do |t|
    t.integer  "payment_id"
    t.integer  "payment_method_id"
    t.integer  "company_payment_method_id"
    t.string   "number",                    default: ""
    t.float    "amount",                    default: 0.0
    t.integer  "installments",              default: 0
    t.integer  "payment_method_type_id"
    t.integer  "bank_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", force: true do |t|
    t.integer  "company_id"
    t.float    "amount",        default: 0.0
    t.boolean  "payed",         default: false
<<<<<<< HEAD
    t.datetime "payment_date",  default: '2015-11-18 15:55:52'
=======
    t.datetime "payment_date",  default: '2015-11-10 14:59:37'
>>>>>>> 45883df860b83e7fb0693daf2b14438b683fcec2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "discount",      default: 0.0
    t.text     "notes",         default: ""
    t.integer  "location_id"
    t.integer  "client_id"
    t.integer  "quantity",      default: 0
    t.float    "paid_amount",   default: 0.0
    t.float    "change_amount", default: 0.0
    t.integer  "cashier_id"
  end

  add_index "payments", ["client_id"], name: "index_payments_on_client_id", using: :btree
  add_index "payments", ["company_id"], name: "index_payments_on_company_id", using: :btree
  add_index "payments", ["location_id"], name: "index_payments_on_location_id", using: :btree

  create_table "petty_cashes", force: true do |t|
    t.integer  "location_id"
    t.float    "cash",                default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "open",                default: false
    t.boolean  "scheduled_close",     default: false
    t.boolean  "scheduled_keep_cash", default: false
    t.float    "scheduled_cash",      default: 0.0
  end

  create_table "petty_transactions", force: true do |t|
    t.integer  "petty_cash_id"
    t.integer  "transactioner_id"
    t.integer  "transactioner_type"
    t.datetime "date"
    t.float    "amount",             default: 0.0
    t.boolean  "is_income",          default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
    t.boolean  "open",               default: true
    t.string   "receipt_number"
  end

  create_table "plan_countries", force: true do |t|
    t.integer  "plan_id"
    t.integer  "country_id"
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "plan_countries", ["country_id"], name: "index_plan_countries_on_country_id", using: :btree
  add_index "plan_countries", ["plan_id"], name: "index_plan_countries_on_plan_id", using: :btree

  create_table "plan_logs", force: true do |t|
    t.integer  "prev_plan_id",               null: false
    t.integer  "new_plan_id",                null: false
    t.integer  "company_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "trx_id"
    t.float    "amount",       default: 0.0, null: false
  end

  add_index "plan_logs", ["company_id"], name: "index_plan_logs_on_company_id", using: :btree

  create_table "plans", force: true do |t|
    t.string   "name",                              null: false
    t.integer  "locations",                         null: false
    t.integer  "service_providers",                 null: false
    t.boolean  "custom",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "special",           default: false
    t.integer  "monthly_mails",     default: 5000,  null: false
  end

  create_table "product_brands", force: true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
  end

  add_index "product_categories", ["company_id"], name: "index_product_categories_on_company_id", using: :btree

  create_table "product_displays", force: true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.integer  "company_id"
    t.text     "name",                default: ""
    t.float    "price",               default: 0.0
    t.text     "description",         default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_category_id",               null: false
    t.string   "sku",                 default: ""
    t.decimal  "comission_value",     default: 0.0, null: false
    t.integer  "comission_option",    default: 0,   null: false
    t.float    "cost"
    t.float    "internal_price"
    t.integer  "product_brand_id"
    t.integer  "product_display_id"
  end

  add_index "products", ["company_id"], name: "index_products_on_company_id", using: :btree
  add_index "products", ["product_category_id"], name: "index_products_on_product_category_id", using: :btree

  create_table "promo_times", force: true do |t|
    t.integer  "company_setting_id"
    t.time     "morning_start",      default: '2000-01-01 09:00:00', null: false
    t.time     "morning_end",        default: '2000-01-01 12:00:00', null: false
    t.time     "afternoon_start",    default: '2000-01-01 12:00:00', null: false
    t.time     "afternoon_end",      default: '2000-01-01 18:00:00', null: false
    t.time     "night_start",        default: '2000-01-01 18:00:00', null: false
    t.time     "night_end",          default: '2000-01-01 20:00:00', null: false
    t.integer  "morning_default",    default: 0
    t.integer  "afternoon_default",  default: 0
    t.integer  "night_default",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",             default: false
  end

  create_table "promos", force: true do |t|
    t.integer  "day_id"
    t.integer  "morning_discount",   default: 0
    t.integer  "afternoon_discount", default: 0
    t.integer  "night_discount",     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
    t.integer  "service_promo_id"
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

  create_table "provider_break_repeats", force: true do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "repeat_option"
    t.string   "repeat_type"
    t.integer  "times"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "provider_breaks", force: true do |t|
    t.datetime "start"
    t.datetime "end"
    t.integer  "service_provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                default: ""
    t.integer  "break_group_id"
    t.integer  "break_repeat_id"
  end

  add_index "provider_breaks", ["service_provider_id"], name: "index_provider_breaks_on_service_provider_id", using: :btree

  create_table "provider_group_auxes", force: true do |t|
    t.integer  "provider_group_id"
    t.integer  "service_provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "provider_group_auxes", ["provider_group_id"], name: "index_provider_group_auxes_on_provider_group_id", using: :btree
  add_index "provider_group_auxes", ["service_provider_id"], name: "index_provider_group_auxes_on_service_provider_id", using: :btree

  create_table "provider_groups", force: true do |t|
    t.integer  "company_id"
    t.string   "name",        default: "", null: false
    t.integer  "order",       default: 0,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
  end

  add_index "provider_groups", ["company_id"], name: "index_provider_groups_on_company_id", using: :btree
  add_index "provider_groups", ["location_id"], name: "index_provider_groups_on_location_id", using: :btree

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

  create_table "ratings", force: true do |t|
    t.integer  "company_id",                       null: false
    t.integer  "location_id",                      null: false
    t.integer  "service_id",                       null: false
    t.integer  "service_provider_id",              null: false
    t.integer  "client_id",                        null: false
    t.integer  "user_id",                          null: false
    t.float    "quality",                          null: false
    t.float    "style",                            null: false
    t.float    "price",                            null: false
    t.float    "overall",                          null: false
    t.text     "comments",            default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["client_id"], name: "index_ratings_on_client_id", using: :btree
  add_index "ratings", ["company_id"], name: "index_ratings_on_company_id", using: :btree
  add_index "ratings", ["location_id"], name: "index_ratings_on_location_id", using: :btree
  add_index "ratings", ["service_id"], name: "index_ratings_on_service_id", using: :btree
  add_index "ratings", ["service_provider_id"], name: "index_ratings_on_service_provider_id", using: :btree
  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id", using: :btree

  create_table "receipt_products", force: true do |t|
    t.integer  "receipt_id"
    t.integer  "product_id"
    t.float    "price"
    t.float    "discount"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "receipt_types", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "receipts", force: true do |t|
    t.integer  "receipt_type_id"
    t.integer  "payment_id"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "number",          default: ""
    t.text     "notes",           default: ""
    t.date     "date"
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

  create_table "sales_cash_emails", force: true do |t|
    t.integer  "sales_cash_id"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales_cash_incomes", force: true do |t|
    t.integer  "sales_cash_id"
    t.integer  "user_id"
    t.float    "amount",        default: 0.0
    t.datetime "date",          default: '2015-11-18 15:55:51'
    t.text     "notes",         default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "open",          default: true
  end

  create_table "sales_cash_logs", force: true do |t|
    t.integer  "sales_cash_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.float    "remaining_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales_cash_transactions", force: true do |t|
    t.integer  "sales_cash_id"
    t.integer  "user_id"
    t.float    "amount",                  default: 0.0
    t.datetime "date",                    default: '2015-11-18 15:55:50'
    t.text     "notes",                   default: ""
    t.string   "receipt_number"
    t.boolean  "is_internal_transaction", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "petty_transaction_id"
    t.boolean  "open",                    default: true
  end

  create_table "sales_cashes", force: true do |t|
    t.integer  "location_id"
    t.float    "cash",                    default: 0.0
    t.integer  "scheduled_reset_day",     default: 1
    t.boolean  "scheduled_reset_monthly", default: true
    t.datetime "last_reset_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "scheduled_reset",         default: false
  end

  create_table "service_categories", force: true do |t|
    t.string   "name",                   null: false
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order",      default: 0
  end

  add_index "service_categories", ["company_id"], name: "index_service_categories_on_company_id", using: :btree

  create_table "service_commissions", force: true do |t|
    t.integer  "service_provider_id"
    t.integer  "service_id"
    t.float    "amount",              default: 0.0
    t.boolean  "is_percent",          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "service_promos", force: true do |t|
    t.integer  "service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "max_bookings",    default: 0
    t.datetime "morning_start",   default: '2000-01-01 09:00:00', null: false
    t.datetime "morning_end",     default: '2000-01-01 12:00:00', null: false
    t.datetime "afternoon_start", default: '2000-01-01 12:00:00', null: false
    t.datetime "afternoon_end",   default: '2000-01-01 18:00:00', null: false
    t.datetime "night_start",     default: '2000-01-01 18:00:00', null: false
    t.datetime "night_end",       default: '2000-01-01 20:00:00', null: false
    t.datetime "finish_date",     default: '2016-01-01 09:00:00'
    t.datetime "book_limit_date", default: '2016-01-01 09:00:00'
    t.boolean  "limit_booking",   default: true
  end

  create_table "service_providers", force: true do |t|
    t.integer  "location_id"
    t.integer  "company_id",                    null: false
    t.string   "public_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",         default: true
    t.integer  "order",          default: 0
    t.integer  "block_length",   default: 15
    t.boolean  "online_booking", default: true
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
    t.string   "name",                                        null: false
    t.float    "price",                       default: 0.0
    t.integer  "duration",                                    null: false
    t.text     "description"
    t.boolean  "group_service",               default: false
    t.integer  "capacity"
    t.boolean  "waiting_list",                default: false
    t.integer  "company_id",                                  null: false
    t.integer  "service_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                      default: true
    t.boolean  "show_price",                  default: true
    t.integer  "order",                       default: 0
    t.boolean  "outcall",                     default: false
    t.boolean  "has_discount",                default: false
    t.float    "discount",                    default: 0.0
    t.boolean  "online_payable",              default: false
    t.decimal  "comission_value",             default: 0.0,   null: false
    t.integer  "comission_option",            default: 0,     null: false
    t.boolean  "online_booking",              default: true
    t.boolean  "has_sessions",                default: false
    t.integer  "sessions_amount"
    t.boolean  "has_time_discount",           default: false
    t.boolean  "has_last_minute_discount",    default: false
    t.boolean  "time_promo_active",           default: false
    t.string   "time_promo_photo"
    t.integer  "active_service_promo_id"
    t.boolean  "must_be_paid_online",         default: false
    t.text     "promo_description",           default: ""
    t.boolean  "has_treatment_promo",         default: false
    t.integer  "active_treatment_promo_id"
    t.integer  "active_last_minute_promo_id"
  end

  add_index "services", ["company_id"], name: "index_services_on_company_id", using: :btree
  add_index "services", ["service_category_id"], name: "index_services_on_service_category_id", using: :btree

  create_table "session_bookings", force: true do |t|
    t.integer  "sessions_taken"
    t.integer  "service_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id"
    t.integer  "sessions_amount",    default: 0
    t.float    "max_discount",       default: 0.0
    t.integer  "treatment_promo_id"
  end

  create_table "staff_codes", force: true do |t|
    t.string   "staff"
    t.string   "code"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "staff_codes", ["company_id"], name: "index_staff_codes_on_company_id", using: :btree

  create_table "stats_companies", force: true do |t|
    t.integer  "company_id",                             null: false
    t.string   "company_name",              default: "", null: false
    t.datetime "company_start"
    t.datetime "last_booking"
    t.integer  "week_bookings",                          null: false
    t.integer  "past_week_bookings",                     null: false
    t.float    "web_bookings",                           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_payment"
    t.string   "last_payment_method"
    t.integer  "company_payment_status_id"
    t.integer  "company_sales_user_id"
  end

  add_index "stats_companies", ["company_id"], name: "index_stats_companies_on_company_id", using: :btree

  create_table "statuses", force: true do |t|
    t.string   "name",        null: false
    t.text     "description", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_alarm_settings", force: true do |t|
    t.integer  "location_id"
    t.boolean  "quick_send",              default: false
    t.boolean  "has_default_stock_limit", default: false
    t.integer  "default_stock_limit",     default: 0
    t.boolean  "monthly",                 default: true
    t.integer  "month_day",               default: 1
    t.integer  "week_day",                default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "periodic_send",           default: false
  end

  create_table "stock_emails", force: true do |t|
    t.integer  "location_product_id"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_setting_emails", force: true do |t|
    t.integer  "stock_alarm_setting_id"
    t.string   "email"
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

  create_table "treatment_promo_locations", force: true do |t|
    t.integer  "treatment_promo_id"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "treatment_promos", force: true do |t|
    t.float    "discount",      default: 0.0
    t.datetime "finish_date"
    t.integer  "max_bookings",  default: 0
    t.boolean  "limit_booking", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "service_id"
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

  create_table "user_searches", force: true do |t|
    t.integer  "user_id"
    t.string   "search_text", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_searches", ["user_id"], name: "index_user_searches_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone",                  default: ""
    t.integer  "role_id",                               null: false
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "provider"
    t.string   "uid"
    t.boolean  "receives_offers",        default: true
    t.string   "mobile_token"
    t.string   "api_token"
  end

  add_index "users", ["company_id"], name: "index_users_on_company_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree

end
