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

ActiveRecord::Schema.define(version: 20160817154204) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

  create_table "app_feeds", force: true do |t|
    t.integer  "company_id"
    t.string   "title"
    t.string   "image"
    t.text     "subtitle"
    t.text     "body"
    t.string   "external_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_feeds", ["company_id"], name: "index_app_feeds_on_company_id", using: :btree

  create_table "attribute_categories", force: true do |t|
    t.integer  "attribute_id"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attribute_categories", ["attribute_id"], name: "index_attribute_categories_on_attribute_id", using: :btree

  create_table "attribute_groups", force: true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attribute_groups", ["company_id"], name: "index_attribute_groups_on_company_id", using: :btree

  create_table "attributes", force: true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.text     "description"
    t.string   "datatype"
    t.boolean  "mandatory"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",                  default: ""
    t.boolean  "show_on_calendar",      default: false
    t.boolean  "show_on_workflow",      default: false
    t.boolean  "mandatory_on_calendar", default: false
    t.boolean  "mandatory_on_workflow", default: false
    t.integer  "attribute_group_id"
    t.integer  "order"
  end

  add_index "attributes", ["attribute_group_id"], name: "index_attributes_on_attribute_group_id", using: :btree
  add_index "attributes", ["company_id"], name: "index_attributes_on_company_id", using: :btree

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
  add_index "billing_logs", ["created_at"], name: "index_billing_logs_on_created_at", order: {"created_at"=>:desc}, using: :btree
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

  add_index "billing_records", ["company_id"], name: "index_billing_records_on_company_id", using: :btree
  add_index "billing_records", ["date"], name: "index_billing_records_on_date", order: {"date"=>:desc}, using: :btree
  add_index "billing_records", ["transaction_type_id"], name: "index_billing_records_on_transaction_type_id", using: :btree

  create_table "billing_wire_transfers", force: true do |t|
    t.datetime "payment_date",   default: '2015-12-02 18:34:34'
    t.float    "amount",         default: 0.0
    t.string   "account_name",   default: ""
    t.string   "account_number", default: ""
    t.boolean  "approved",       default: false
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "change_plan",    default: false
    t.integer  "new_plan"
    t.integer  "bank_id"
    t.integer  "paid_months"
  end

  add_index "billing_wire_transfers", ["company_id"], name: "index_billing_wire_transfers_on_company_id", using: :btree
  add_index "billing_wire_transfers", ["payment_date"], name: "index_billing_wire_transfers_on_payment_date", order: {"payment_date"=>:desc}, using: :btree

  create_table "booking_email_logs", force: true do |t|
    t.integer  "booking_id"
    t.string   "transmission_id"
    t.string   "status"
    t.string   "subject"
    t.string   "recipient"
    t.datetime "timestamp"
    t.integer  "opens",           default: 0
    t.integer  "clicks",          default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "progress",        default: 0
    t.text     "details",         default: ""
  end

  add_index "booking_email_logs", ["booking_id"], name: "index_booking_email_logs_on_booking_id", using: :btree
  add_index "booking_email_logs", ["timestamp"], name: "index_booking_email_logs_on_timestamp", using: :btree

  create_table "booking_histories", force: true do |t|
    t.integer  "booking_id"
    t.string   "action"
    t.datetime "start"
    t.integer  "status_id"
    t.integer  "service_id"
    t.integer  "service_provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.text     "notes"
    t.text     "company_comment"
    t.integer  "employee_code_id"
  end

  add_index "booking_histories", ["booking_id"], name: "index_booking_histories_on_booking_id", using: :btree
  add_index "booking_histories", ["created_at"], name: "index_booking_histories_on_created_at", order: {"created_at"=>:desc}, using: :btree
  add_index "booking_histories", ["employee_code_id"], name: "index_booking_histories_on_employee_code_id", using: :btree
  add_index "booking_histories", ["service_id"], name: "index_booking_histories_on_service_id", using: :btree
  add_index "booking_histories", ["service_provider_id"], name: "index_booking_histories_on_service_provider_id", using: :btree
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
    t.integer  "max_changes",            default: 2
    t.boolean  "payed",                  default: false
    t.string   "trx_id",                 default: ""
    t.string   "token",                  default: ""
    t.integer  "deal_id"
    t.integer  "booking_group"
    t.integer  "payed_booking_id"
    t.integer  "payment_id"
    t.boolean  "is_session",             default: false
    t.integer  "session_booking_id"
    t.boolean  "user_session_confirmed", default: false
    t.boolean  "is_session_booked",      default: false
    t.float    "discount",               default: 0.0
    t.integer  "service_promo_id"
    t.integer  "reminder_group"
    t.boolean  "is_booked",              default: true
    t.float    "list_price",             default: 0.0
    t.integer  "receipt_id"
    t.boolean  "payed_state",            default: false
    t.boolean  "marketplace_origin",     default: false
    t.integer  "treatment_promo_id"
    t.integer  "last_minute_promo_id"
    t.boolean  "bundled",                default: false
    t.integer  "bundle_id"
    t.integer  "survey_construct_id"
  end

  add_index "bookings", ["bundle_id"], name: "index_bookings_on_bundle_id", using: :btree
  add_index "bookings", ["client_id"], name: "index_bookings_on_client_id", using: :btree
  add_index "bookings", ["deal_id"], name: "index_bookings_on_deal_id", using: :btree
  add_index "bookings", ["location_id"], name: "index_bookings_on_location_id", using: :btree
  add_index "bookings", ["payment_id"], name: "index_bookings_on_payment_id", where: "(payment_id IS NOT NULL)", using: :btree
  add_index "bookings", ["promotion_id"], name: "index_bookings_on_promotion_id", using: :btree
  add_index "bookings", ["service_id"], name: "index_bookings_on_service_id", using: :btree
  add_index "bookings", ["service_provider_id"], name: "index_bookings_on_service_provider_id", using: :btree
  add_index "bookings", ["session_booking_id"], name: "index_bookings_on_session_booking_id", using: :btree
  add_index "bookings", ["start"], name: "index_bookings_on_start", using: :btree
  add_index "bookings", ["status_id"], name: "index_bookings_on_status_id", using: :btree
  add_index "bookings", ["survey_construct_id"], name: "index_bookings_on_survey_construct_id", using: :btree
  add_index "bookings", ["user_id"], name: "index_bookings_on_user_id", using: :btree

  create_table "boolean_attributes", force: true do |t|
    t.integer  "attribute_id"
    t.integer  "client_id"
    t.boolean  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "boolean_attributes", ["attribute_id"], name: "index_boolean_attributes_on_attribute_id", using: :btree
  add_index "boolean_attributes", ["client_id"], name: "index_boolean_attributes_on_client_id", using: :btree

  create_table "boolean_custom_filters", force: true do |t|
    t.integer  "custom_filter_id"
    t.integer  "attribute_id"
    t.boolean  "option"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "boolean_custom_filters", ["attribute_id"], name: "index_boolean_custom_filters_on_attribute_id", using: :btree
  add_index "boolean_custom_filters", ["custom_filter_id"], name: "index_boolean_custom_filters_on_custom_filter_id", using: :btree

  create_table "bundles", force: true do |t|
    t.string   "name",                default: "",   null: false
    t.decimal  "price",               default: 0.0,  null: false
    t.integer  "service_category_id"
    t.integer  "company_id"
    t.text     "description",         default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_price",          default: true
  end

  add_index "bundles", ["company_id"], name: "index_bundles_on_company_id", using: :btree
  add_index "bundles", ["service_category_id"], name: "index_bundles_on_service_category_id", using: :btree

  create_table "cashiers", force: true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "code"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cashiers", ["company_id"], name: "index_cashiers_on_company_id", using: :btree

  create_table "categoric_attributes", force: true do |t|
    t.integer  "client_id"
    t.integer  "attribute_id"
    t.integer  "attribute_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categoric_attributes", ["attribute_category_id"], name: "index_categoric_attributes_on_attribute_category_id", using: :btree
  add_index "categoric_attributes", ["attribute_id"], name: "index_categoric_attributes_on_attribute_id", using: :btree
  add_index "categoric_attributes", ["client_id"], name: "index_categoric_attributes_on_client_id", using: :btree

  create_table "categoric_custom_filters", force: true do |t|
    t.integer  "custom_filter_id"
    t.integer  "attribute_id"
    t.string   "categories_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categoric_custom_filters", ["attribute_id"], name: "index_categoric_custom_filters_on_attribute_id", using: :btree
  add_index "categoric_custom_filters", ["custom_filter_id"], name: "index_categoric_custom_filters_on_custom_filter_id", using: :btree

  create_table "chart_categories", force: true do |t|
    t.integer  "chart_field_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chart_categories", ["chart_field_id"], name: "index_chart_categories_on_chart_field_id", using: :btree

  create_table "chart_field_booleans", force: true do |t|
    t.integer  "chart_field_id"
    t.boolean  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chart_id"
  end

  add_index "chart_field_booleans", ["chart_field_id"], name: "index_chart_field_booleans_on_chart_field_id", using: :btree
  add_index "chart_field_booleans", ["chart_id"], name: "index_chart_field_booleans_on_chart_id", using: :btree

  create_table "chart_field_categorics", force: true do |t|
    t.integer  "chart_field_id"
    t.integer  "chart_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chart_id"
  end

  add_index "chart_field_categorics", ["chart_category_id"], name: "index_chart_field_categorics_on_chart_category_id", using: :btree
  add_index "chart_field_categorics", ["chart_field_id"], name: "index_chart_field_categorics_on_chart_field_id", using: :btree
  add_index "chart_field_categorics", ["chart_id"], name: "index_chart_field_categorics_on_chart_id", using: :btree

  create_table "chart_field_dates", force: true do |t|
    t.integer  "chart_field_id"
    t.date     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chart_id"
  end

  add_index "chart_field_dates", ["chart_field_id"], name: "index_chart_field_dates_on_chart_field_id", using: :btree
  add_index "chart_field_dates", ["chart_id"], name: "index_chart_field_dates_on_chart_id", using: :btree

  create_table "chart_field_datetimes", force: true do |t|
    t.integer  "chart_field_id"
    t.datetime "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chart_id"
  end

  add_index "chart_field_datetimes", ["chart_field_id"], name: "index_chart_field_datetimes_on_chart_field_id", using: :btree
  add_index "chart_field_datetimes", ["chart_id"], name: "index_chart_field_datetimes_on_chart_id", using: :btree

  create_table "chart_field_files", force: true do |t|
    t.integer  "chart_field_id"
    t.integer  "client_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chart_id"
  end

  add_index "chart_field_files", ["chart_field_id"], name: "index_chart_field_files_on_chart_field_id", using: :btree
  add_index "chart_field_files", ["chart_id"], name: "index_chart_field_files_on_chart_id", using: :btree
  add_index "chart_field_files", ["client_file_id"], name: "index_chart_field_files_on_client_file_id", using: :btree

  create_table "chart_field_floats", force: true do |t|
    t.integer  "chart_field_id"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chart_id"
  end

  add_index "chart_field_floats", ["chart_field_id"], name: "index_chart_field_floats_on_chart_field_id", using: :btree
  add_index "chart_field_floats", ["chart_id"], name: "index_chart_field_floats_on_chart_id", using: :btree

  create_table "chart_field_integers", force: true do |t|
    t.integer  "chart_field_id"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chart_id"
  end

  add_index "chart_field_integers", ["chart_field_id"], name: "index_chart_field_integers_on_chart_field_id", using: :btree
  add_index "chart_field_integers", ["chart_id"], name: "index_chart_field_integers_on_chart_id", using: :btree

  create_table "chart_field_textareas", force: true do |t|
    t.integer  "chart_field_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chart_id"
  end

  add_index "chart_field_textareas", ["chart_field_id"], name: "index_chart_field_textareas_on_chart_field_id", using: :btree
  add_index "chart_field_textareas", ["chart_id"], name: "index_chart_field_textareas_on_chart_id", using: :btree

  create_table "chart_field_texts", force: true do |t|
    t.integer  "chart_field_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chart_id"
  end

  add_index "chart_field_texts", ["chart_field_id"], name: "index_chart_field_texts_on_chart_field_id", using: :btree
  add_index "chart_field_texts", ["chart_id"], name: "index_chart_field_texts_on_chart_id", using: :btree

  create_table "chart_fields", force: true do |t|
    t.integer  "company_id"
    t.integer  "chart_group_id"
    t.string   "name"
    t.text     "description"
    t.string   "datatype"
    t.string   "slug"
    t.boolean  "mandatory"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chart_fields", ["chart_group_id"], name: "index_chart_fields_on_chart_group_id", using: :btree
  add_index "chart_fields", ["company_id"], name: "index_chart_fields_on_company_id", using: :btree

  create_table "chart_groups", force: true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chart_groups", ["company_id"], name: "index_chart_groups_on_company_id", using: :btree

  create_table "charts", force: true do |t|
    t.integer  "company_id"
    t.integer  "client_id"
    t.integer  "booking_id"
    t.integer  "user_id"
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_modifier_id"
  end

  add_index "charts", ["booking_id"], name: "index_charts_on_booking_id", using: :btree
  add_index "charts", ["client_id"], name: "index_charts_on_client_id", using: :btree
  add_index "charts", ["company_id"], name: "index_charts_on_company_id", using: :btree
  add_index "charts", ["last_modifier_id"], name: "index_charts_on_last_modifier_id", using: :btree
  add_index "charts", ["user_id"], name: "index_charts_on_user_id", using: :btree

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
  add_index "client_comments", ["created_at"], name: "index_client_comments_on_created_at", order: {"created_at"=>:desc}, using: :btree

  create_table "client_email_logs", force: true do |t|
    t.integer  "client_id"
    t.integer  "campaign_id"
    t.string   "transmission_id"
    t.string   "status"
    t.string   "subject"
    t.string   "recipient"
    t.datetime "timestamp"
    t.integer  "opens",           default: 0
    t.integer  "clicks",          default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "progress",        default: 0
    t.text     "details",         default: ""
  end

  add_index "client_email_logs", ["client_id"], name: "index_client_email_logs_on_client_id", using: :btree
  add_index "client_email_logs", ["timestamp"], name: "index_client_email_logs_on_timestamp", using: :btree

  create_table "client_files", force: true do |t|
    t.integer  "client_id"
    t.text     "name"
    t.text     "full_path"
    t.text     "public_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "size",        default: 0
    t.text     "description", default: ""
    t.string   "folder",      default: ""
  end

  add_index "client_files", ["client_id"], name: "index_client_files_on_client_id", using: :btree

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
    t.integer  "default_plan_id",     default: 10
  end

  add_index "companies", ["country_id"], name: "index_companies_on_country_id", using: :btree
  add_index "companies", ["payment_status_id"], name: "index_companies_on_payment_status_id", using: :btree
  add_index "companies", ["plan_id"], name: "index_companies_on_plan_id", using: :btree
  add_index "companies", ["sales_user_id"], name: "index_companies_on_sales_user_id", using: :btree

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

  add_index "company_cron_logs", ["company_id"], name: "index_company_cron_logs_on_company_id", using: :btree

  create_table "company_economic_sectors", force: true do |t|
    t.integer  "company_id"
    t.integer  "economic_sector_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "company_economic_sectors", ["company_id"], name: "index_company_economic_sectors_on_company_id", using: :btree
  add_index "company_economic_sectors", ["economic_sector_id"], name: "index_company_economic_sectors_on_economic_sector_id", using: :btree

  create_table "company_files", force: true do |t|
    t.integer  "company_id"
    t.text     "name"
    t.text     "full_path"
    t.text     "public_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "size",        default: 0
    t.text     "description", default: ""
    t.string   "folder",      default: ""
  end

  add_index "company_files", ["company_id"], name: "index_company_files_on_company_id", using: :btree

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
    t.float    "base_price"
    t.float    "locations_multiplier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "company_plan_settings", ["company_id"], name: "index_company_plan_settings_on_company_id", using: :btree

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
    t.boolean  "deal_activate",               default: false
    t.string   "deal_name",                   default: ""
    t.boolean  "deal_overcharge",             default: true
    t.boolean  "allows_online_payment",       default: false
    t.string   "account_number",              default: ""
    t.string   "company_rut",                 default: ""
    t.string   "account_name",                default: ""
    t.integer  "account_type",                default: 3
    t.integer  "bank_id"
    t.boolean  "deal_exclusive",              default: true
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
    t.text     "preset_notes"
    t.boolean  "payment_client_required",     default: true
    t.boolean  "show_cashes",                 default: false
    t.boolean  "editable_payment_prices",     default: true
    t.boolean  "mandatory_mock_booking_info", default: false
    t.boolean  "strict_booking",              default: false,                 null: false
    t.integer  "mails_base_capacity",         default: 5000
    t.integer  "booking_leap",                default: 15
    t.boolean  "allows_overlap_hours",        default: false
    t.boolean  "require_cashier_code",        default: true
    t.string   "color_light"
    t.string   "color_normal"
    t.string   "color_dark"
    t.integer  "after_survey"
    t.integer  "activate_survey"
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
    t.string   "timezone_name"
    t.float    "timezone_offset"
  end

  create_table "custom_filters", force: true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "custom_filters", ["company_id"], name: "index_custom_filters_on_company_id", using: :btree

  create_table "date_attributes", force: true do |t|
    t.integer  "attribute_id"
    t.integer  "client_id"
    t.date     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "date_attributes", ["attribute_id"], name: "index_date_attributes_on_attribute_id", using: :btree
  add_index "date_attributes", ["client_id"], name: "index_date_attributes_on_client_id", using: :btree

  create_table "date_custom_filters", force: true do |t|
    t.integer  "custom_filter_id"
    t.integer  "attribute_id"
    t.datetime "date1"
    t.datetime "date2"
    t.string   "option"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "exclusive1",       default: true
    t.boolean  "exclusive2",       default: true
  end

  add_index "date_custom_filters", ["attribute_id"], name: "index_date_custom_filters_on_attribute_id", using: :btree
  add_index "date_custom_filters", ["custom_filter_id"], name: "index_date_custom_filters_on_custom_filter_id", using: :btree

  create_table "date_time_attributes", force: true do |t|
    t.integer  "attribute_id"
    t.integer  "client_id"
    t.datetime "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "date_time_attributes", ["attribute_id"], name: "index_date_time_attributes_on_attribute_id", using: :btree
  add_index "date_time_attributes", ["client_id"], name: "index_date_time_attributes_on_client_id", using: :btree

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

  create_table "downgrade_logs", force: true do |t|
    t.integer  "company_id"
    t.integer  "plan_id"
    t.float    "debt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "downgrade_logs", ["company_id"], name: "index_downgrade_logs_on_company_id", using: :btree
  add_index "downgrade_logs", ["plan_id"], name: "index_downgrade_logs_on_plan_id", using: :btree

  create_table "economic_sectors", force: true do |t|
    t.string   "name",                                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_in_home",              default: true
    t.boolean  "show_in_company",           default: true
    t.string   "mobile_preview",            default: ""
    t.boolean  "marketplace",               default: false
    t.integer  "marketplace_categories_id"
    t.integer  "marketplace_category_id"
  end

  add_index "economic_sectors", ["marketplace_categories_id"], name: "index_economic_sectors_on_marketplace_categories_id", using: :btree
  add_index "economic_sectors", ["marketplace_category_id"], name: "index_economic_sectors_on_marketplace_category_id", using: :btree

  create_table "economic_sectors_dictionaries", force: true do |t|
    t.string   "name"
    t.integer  "economic_sector_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "economic_sectors_dictionaries", ["economic_sector_id"], name: "index_economic_sectors_dictionaries_on_economic_sector_id", using: :btree

  create_table "email_blacklists", force: true do |t|
    t.string   "email"
    t.string   "sender"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_contents", force: true do |t|
    t.integer  "template_id"
    t.json     "data",                              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "from"
    t.text     "to"
    t.string   "subject"
    t.integer  "company_id"
    t.string   "name"
    t.boolean  "active",             default: true
    t.datetime "deactivation_date"
    t.text     "attachment_content"
    t.string   "attachment_type"
    t.string   "attachment_name"
  end

  add_index "email_contents", ["company_id"], name: "index_email_contents_on_company_id", using: :btree
  add_index "email_contents", ["template_id"], name: "index_email_contents_on_template_id", using: :btree

  create_table "email_exclusions", force: true do |t|
    t.string   "domain"
    t.boolean  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_sendings", force: true do |t|
    t.integer  "sendable_id"
    t.string   "sendable_type"
    t.datetime "send_date"
    t.datetime "sent_date"
    t.string   "status",           default: "pending"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_sendings",   default: 0
    t.integer  "total_recipients", default: 0
    t.json     "detail"
    t.string   "method"
    t.integer  "total_targets"
  end

  create_table "email_templates", force: true do |t|
    t.string   "name"
    t.string   "source"
    t.string   "thumb"
    t.boolean  "active",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employee_codes", force: true do |t|
    t.string   "name"
    t.string   "code"
    t.integer  "company_id"
    t.boolean  "active"
    t.boolean  "staff"
    t.boolean  "cashier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "employee_codes", ["company_id"], name: "index_employee_codes_on_company_id", using: :btree

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

  create_table "file_attributes", force: true do |t|
    t.integer  "attribute_id"
    t.integer  "client_id"
    t.integer  "client_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "file_attributes", ["attribute_id"], name: "index_file_attributes_on_attribute_id", using: :btree
  add_index "file_attributes", ["client_id"], name: "index_file_attributes_on_client_id", using: :btree

  create_table "float_attributes", force: true do |t|
    t.integer  "attribute_id"
    t.integer  "client_id"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "float_attributes", ["attribute_id"], name: "index_float_attributes_on_attribute_id", using: :btree
  add_index "float_attributes", ["client_id"], name: "index_float_attributes_on_client_id", using: :btree

  create_table "integer_attributes", force: true do |t|
    t.integer  "attribute_id"
    t.integer  "client_id"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "integer_attributes", ["attribute_id"], name: "index_integer_attributes_on_attribute_id", using: :btree
  add_index "integer_attributes", ["client_id"], name: "index_integer_attributes_on_client_id", using: :btree

  create_table "internal_sales", force: true do |t|
    t.integer  "location_id"
    t.integer  "service_provider_id"
    t.integer  "product_id"
    t.integer  "quantity",            default: 1
    t.float    "list_price",          default: 0.0
    t.float    "price",               default: 0.0
    t.float    "discount",            default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "date",                default: '2015-10-30 21:54:55'
    t.integer  "user_id"
    t.text     "notes",               default: ""
    t.integer  "employee_code_id"
  end

  add_index "internal_sales", ["date"], name: "index_internal_sales_on_date", order: {"date"=>:desc}, using: :btree
  add_index "internal_sales", ["employee_code_id"], name: "index_internal_sales_on_employee_code_id", using: :btree
  add_index "internal_sales", ["location_id"], name: "index_internal_sales_on_location_id", using: :btree
  add_index "internal_sales", ["product_id"], name: "index_internal_sales_on_product_id", using: :btree
  add_index "internal_sales", ["service_provider_id"], name: "index_internal_sales_on_service_provider_id", using: :btree
  add_index "internal_sales", ["user_id"], name: "index_internal_sales_on_user_id", using: :btree

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

  create_table "location_open_days", force: true do |t|
    t.integer  "location_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "location_open_days", ["end_time"], name: "index_location_open_days_on_end_time", using: :btree
  add_index "location_open_days", ["location_id"], name: "index_location_open_days_on_location_id", using: :btree
  add_index "location_open_days", ["start_time"], name: "index_location_open_days_on_start_time", using: :btree

  create_table "location_products", force: true do |t|
    t.integer  "product_id"
    t.integer  "location_id"
    t.integer  "stock"
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
    t.json     "address",                        null: false
    t.string   "phone",                          null: false
    t.float    "latitude"
    t.float    "longitude"
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
    t.text     "outcall_places"
    t.integer  "country_id"
  end

  add_index "locations", ["company_id"], name: "index_locations_on_company_id", using: :btree
  add_index "locations", ["country_id"], name: "index_locations_on_country_id", using: :btree

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

  add_index "mock_bookings", ["client_id"], name: "index_mock_bookings_on_client_id", where: "(client_id IS NOT NULL)", using: :btree
  add_index "mock_bookings", ["payment_id"], name: "index_mock_bookings_on_payment_id", using: :btree
  add_index "mock_bookings", ["receipt_id"], name: "index_mock_bookings_on_receipt_id", using: :btree
  add_index "mock_bookings", ["service_id"], name: "index_mock_bookings_on_service_id", where: "(service_id IS NOT NULL)", using: :btree
  add_index "mock_bookings", ["service_provider_id"], name: "index_mock_bookings_on_service_provider_id", where: "(service_provider_id IS NOT NULL)", using: :btree

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

  create_table "numeric_custom_filters", force: true do |t|
    t.integer  "custom_filter_id"
    t.integer  "attribute_id"
    t.float    "value1"
    t.float    "value2"
    t.string   "option"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "exclusive1",       default: true
    t.boolean  "exclusive2",       default: true
  end

  add_index "numeric_custom_filters", ["attribute_id"], name: "index_numeric_custom_filters_on_attribute_id", using: :btree
  add_index "numeric_custom_filters", ["custom_filter_id"], name: "index_numeric_custom_filters_on_custom_filter_id", using: :btree

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

  add_index "online_cancelation_policies", ["company_setting_id"], name: "index_online_cancelation_policies_on_company_setting_id", using: :btree

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

  add_index "payed_bookings", ["payment_account_id"], name: "index_payed_bookings_on_payment_account_id", using: :btree
  add_index "payed_bookings", ["punto_pagos_confirmation_id"], name: "index_payed_bookings_on_punto_pagos_confirmation_id", using: :btree

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

  add_index "payment_accounts", ["company_id"], name: "index_payment_accounts_on_company_id", using: :btree

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
    t.float    "list_price",  default: 0.0
    t.integer  "receipt_id"
  end

  add_index "payment_products", ["payment_id"], name: "index_payment_products_on_payment_id", using: :btree
  add_index "payment_products", ["product_id"], name: "index_payment_products_on_product_id", using: :btree
  add_index "payment_products", ["receipt_id"], name: "index_payment_products_on_receipt_id", using: :btree
  add_index "payment_products", ["seller_id"], name: "index_payment_products_on_seller_id", where: "(seller_id IS NOT NULL)", using: :btree

  create_table "payment_sendings", force: true do |t|
    t.integer "payment_id"
    t.string  "emails"
  end

  add_index "payment_sendings", ["payment_id"], name: "index_payment_sendings_on_payment_id", using: :btree

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

  add_index "payment_transactions", ["company_payment_method_id"], name: "index_payment_transactions_on_company_payment_method_id", using: :btree
  add_index "payment_transactions", ["payment_id"], name: "index_payment_transactions_on_payment_id", using: :btree
  add_index "payment_transactions", ["payment_method_id"], name: "index_payment_transactions_on_payment_method_id", using: :btree
  add_index "payment_transactions", ["payment_method_type_id"], name: "index_payment_transactions_on_payment_method_type_id", using: :btree

  create_table "payments", force: true do |t|
    t.integer  "company_id"
    t.float    "amount",           default: 0.0
    t.boolean  "payed",            default: false
    t.datetime "payment_date",     default: '2015-11-12 13:16:44'
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "discount",         default: 0.0
    t.text     "notes",            default: ""
    t.integer  "location_id"
    t.integer  "client_id"
    t.integer  "quantity",         default: 0
    t.float    "paid_amount",      default: 0.0
    t.float    "change_amount",    default: 0.0
    t.integer  "employee_code_id"
  end

  add_index "payments", ["client_id"], name: "index_payments_on_client_id", using: :btree
  add_index "payments", ["company_id"], name: "index_payments_on_company_id", using: :btree
  add_index "payments", ["created_at"], name: "index_payments_on_created_at", order: {"created_at"=>:desc}, using: :btree
  add_index "payments", ["employee_code_id"], name: "index_payments_on_employee_code_id", using: :btree
  add_index "payments", ["location_id"], name: "index_payments_on_location_id", using: :btree
  add_index "payments", ["payment_date"], name: "index_payments_on_payment_date", order: {"payment_date"=>:desc}, using: :btree

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

  add_index "petty_cashes", ["location_id"], name: "index_petty_cashes_on_location_id", using: :btree

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

  add_index "petty_transactions", ["date"], name: "index_petty_transactions_on_date", order: {"date"=>:desc}, using: :btree
  add_index "petty_transactions", ["petty_cash_id"], name: "index_petty_transactions_on_petty_cash_id", using: :btree

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

  add_index "product_brands", ["company_id"], name: "index_product_brands_on_company_id", using: :btree

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

  add_index "product_displays", ["company_id"], name: "index_product_displays_on_company_id", using: :btree

  create_table "product_logs", force: true do |t|
    t.integer  "product_id"
    t.integer  "internal_sale_id"
    t.integer  "payment_product_id"
    t.integer  "service_provider_id"
    t.integer  "client_id"
    t.string   "change"
    t.text     "cause"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
    t.integer  "user_id"
  end

  add_index "product_logs", ["client_id"], name: "index_product_logs_on_client_id", using: :btree
  add_index "product_logs", ["internal_sale_id"], name: "index_product_logs_on_internal_sale_id", using: :btree
  add_index "product_logs", ["location_id"], name: "index_product_logs_on_location_id", using: :btree
  add_index "product_logs", ["payment_product_id"], name: "index_product_logs_on_payment_product_id", using: :btree
  add_index "product_logs", ["product_id"], name: "index_product_logs_on_product_id", using: :btree
  add_index "product_logs", ["service_provider_id"], name: "index_product_logs_on_service_provider_id", using: :btree
  add_index "product_logs", ["user_id"], name: "index_product_logs_on_user_id", using: :btree

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
  add_index "products", ["product_brand_id"], name: "index_products_on_product_brand_id", using: :btree
  add_index "products", ["product_category_id"], name: "index_products_on_product_category_id", using: :btree
  add_index "products", ["product_display_id"], name: "index_products_on_product_display_id", using: :btree

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
    t.integer  "weeks",         default: 0
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

  add_index "provider_breaks", ["break_group_id"], name: "index_provider_breaks_on_break_group_id", using: :btree
  add_index "provider_breaks", ["break_repeat_id"], name: "index_provider_breaks_on_break_repeat_id", using: :btree
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

  create_table "provider_open_days", force: true do |t|
    t.integer  "service_provider_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "provider_open_days", ["end_time"], name: "index_provider_open_days_on_end_time", using: :btree
  add_index "provider_open_days", ["service_provider_id"], name: "index_provider_open_days_on_service_provider_id", using: :btree
  add_index "provider_open_days", ["start_time"], name: "index_provider_open_days_on_start_time", using: :btree

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

  add_index "receipt_products", ["product_id"], name: "index_receipt_products_on_product_id", using: :btree
  add_index "receipt_products", ["receipt_id"], name: "index_receipt_products_on_receipt_id", using: :btree

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

  add_index "receipts", ["payment_id"], name: "index_receipts_on_payment_id", using: :btree
  add_index "receipts", ["receipt_type_id"], name: "index_receipts_on_receipt_type_id", using: :btree

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
    t.datetime "date",          default: '2015-10-30 21:54:55'
    t.text     "notes",         default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "open",          default: true
  end

  add_index "sales_cash_incomes", ["sales_cash_id"], name: "index_sales_cash_incomes_on_sales_cash_id", using: :btree
  add_index "sales_cash_incomes", ["user_id"], name: "index_sales_cash_incomes_on_user_id", using: :btree

  create_table "sales_cash_logs", force: true do |t|
    t.integer  "sales_cash_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.float    "remaining_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sales_cash_logs", ["sales_cash_id"], name: "index_sales_cash_logs_on_sales_cash_id", using: :btree

  create_table "sales_cash_transactions", force: true do |t|
    t.integer  "sales_cash_id"
    t.integer  "user_id"
    t.float    "amount",                  default: 0.0
    t.datetime "date",                    default: '2015-10-30 21:54:55'
    t.text     "notes",                   default: ""
    t.string   "receipt_number"
    t.boolean  "is_internal_transaction", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "petty_transaction_id"
    t.boolean  "open",                    default: true
  end

  add_index "sales_cash_transactions", ["sales_cash_id"], name: "index_sales_cash_transactions_on_sales_cash_id", using: :btree
  add_index "sales_cash_transactions", ["user_id"], name: "index_sales_cash_transactions_on_user_id", using: :btree

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

  add_index "sales_cashes", ["location_id"], name: "index_sales_cashes_on_location_id", using: :btree

  create_table "service_bundles", force: true do |t|
    t.integer  "service_id"
    t.integer  "bundle_id"
    t.integer  "order",      default: 0,   null: false
    t.decimal  "price",      default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "service_bundles", ["bundle_id"], name: "index_service_bundles_on_bundle_id", using: :btree
  add_index "service_bundles", ["service_id"], name: "index_service_bundles_on_service_id", using: :btree

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

  add_index "service_commissions", ["service_id"], name: "index_service_commissions_on_service_id", using: :btree
  add_index "service_commissions", ["service_provider_id"], name: "index_service_commissions_on_service_provider_id", using: :btree

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
    t.integer  "booking_leap",   default: 15
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

  create_table "service_survey_constructs", force: true do |t|
    t.integer  "service_id"
    t.integer  "survey_construct_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "service_survey_constructs", ["service_id"], name: "index_service_survey_constructs_on_service_id", using: :btree
  add_index "service_survey_constructs", ["survey_construct_id"], name: "index_service_survey_constructs_on_survey_construct_id", using: :btree

  create_table "service_tags", force: true do |t|
    t.integer  "service_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "service_tags", ["service_id"], name: "index_service_tags_on_service_id", using: :btree
  add_index "service_tags", ["tag_id"], name: "index_service_tags_on_tag_id", using: :btree

  create_table "service_times", force: true do |t|
    t.time     "open",       null: false
    t.time     "close",      null: false
    t.integer  "service_id"
    t.integer  "day_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "service_times", ["day_id"], name: "index_service_times_on_day_id", using: :btree
  add_index "service_times", ["service_id"], name: "index_service_times_on_service_id", using: :btree

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
    t.string   "time_promo_photo",            default: ""
    t.integer  "active_service_promo_id"
    t.boolean  "must_be_paid_online",         default: false
    t.text     "promo_description",           default: ""
    t.boolean  "has_treatment_promo",         default: false
    t.integer  "active_treatment_promo_id"
    t.integer  "active_last_minute_promo_id"
    t.boolean  "time_restricted",             default: false
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

  add_index "session_bookings", ["client_id"], name: "index_session_bookings_on_client_id", using: :btree
  add_index "session_bookings", ["service_id"], name: "index_session_bookings_on_service_id", using: :btree
  add_index "session_bookings", ["user_id"], name: "index_session_bookings_on_user_id", using: :btree

  create_table "sparkpost_email_logs", force: true do |t|
    t.text     "raw_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "pending_process", default: false
  end

  create_table "sparkpost_statuses", force: true do |t|
    t.string   "event_type"
    t.string   "status"
    t.integer  "progress",   default: 0
    t.boolean  "blacklist",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staff_codes", force: true do |t|
    t.string   "staff"
    t.string   "code"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     default: true
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

  add_index "stock_alarm_settings", ["location_id"], name: "index_stock_alarm_settings_on_location_id", using: :btree

  create_table "stock_emails", force: true do |t|
    t.integer  "location_product_id"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stock_emails", ["location_product_id"], name: "index_stock_emails_on_location_product_id", using: :btree

  create_table "stock_setting_emails", force: true do |t|
    t.integer  "stock_alarm_setting_id"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stock_setting_emails", ["stock_alarm_setting_id"], name: "index_stock_setting_emails_on_stock_alarm_setting_id", using: :btree

  create_table "super_admin_logs", force: true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.text     "detail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "super_admin_logs", ["company_id"], name: "index_super_admin_logs_on_company_id", using: :btree
  add_index "super_admin_logs", ["user_id"], name: "index_super_admin_logs_on_user_id", using: :btree

  create_table "survey_categories", force: true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_categories", ["company_id"], name: "index_survey_categories_on_company_id", using: :btree

  create_table "survey_constructs", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
  end

  add_index "survey_constructs", ["company_id"], name: "index_survey_constructs_on_company_id", using: :btree

  create_table "survey_questions", force: true do |t|
    t.string   "question"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "survey_construct_id"
    t.integer  "type_question"
    t.integer  "order"
  end

  add_index "survey_questions", ["survey_construct_id"], name: "index_survey_questions_on_survey_construct_id", using: :btree

  create_table "surveys", force: true do |t|
    t.integer  "quality"
    t.integer  "style"
    t.integer  "satifaction"
    t.text     "comment"
    t.integer  "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "booking_id"
  end

  add_index "surveys", ["booking_id"], name: "index_surveys_on_booking_id", using: :btree
  add_index "surveys", ["client_id"], name: "index_surveys_on_client_id", using: :btree

  create_table "tags", force: true do |t|
    t.string   "name",               null: false
    t.integer  "economic_sector_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["economic_sector_id"], name: "index_tags_on_economic_sector_id", using: :btree

  create_table "text_attributes", force: true do |t|
    t.integer  "attribute_id"
    t.integer  "client_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "text_attributes", ["attribute_id"], name: "index_text_attributes_on_attribute_id", using: :btree
  add_index "text_attributes", ["client_id"], name: "index_text_attributes_on_client_id", using: :btree

  create_table "text_custom_filters", force: true do |t|
    t.integer  "custom_filter_id"
    t.integer  "attribute_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "text_custom_filters", ["attribute_id"], name: "index_text_custom_filters_on_attribute_id", using: :btree
  add_index "text_custom_filters", ["custom_filter_id"], name: "index_text_custom_filters_on_custom_filter_id", using: :btree

  create_table "textarea_attributes", force: true do |t|
    t.integer  "attribute_id"
    t.integer  "client_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "textarea_attributes", ["attribute_id"], name: "index_textarea_attributes_on_attribute_id", using: :btree
  add_index "textarea_attributes", ["client_id"], name: "index_textarea_attributes_on_client_id", using: :btree

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

  create_table "treatment_logs", force: true do |t|
    t.integer  "client_id"
    t.integer  "user_id"
    t.integer  "service_id"
    t.text     "detail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "treatment_logs", ["client_id"], name: "index_treatment_logs_on_client_id", using: :btree
  add_index "treatment_logs", ["service_id"], name: "index_treatment_logs_on_service_id", using: :btree
  add_index "treatment_logs", ["user_id"], name: "index_treatment_logs_on_user_id", using: :btree

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
