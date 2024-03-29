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

ActiveRecord::Schema.define(version: 20140808061826) do

  create_table "date_night_slots", force: true do |t|
    t.date     "available_on"
    t.datetime "starting_at"
    t.integer  "guaranteed_openings"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", force: true do |t|
    t.string   "type"
    t.string   "email"
    t.string   "phone"
    t.string   "password_hash"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.date     "date_of_birth"
    t.string   "merchant_account_id"
    t.string   "payment_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "accepted_tou_at"
    t.string   "sso_uuid"
  end

  add_index "members", ["email"], name: "index_members_on_email", unique: true, using: :btree
  add_index "members", ["merchant_account_id"], name: "index_members_on_merchant_account_id", unique: true, using: :btree
  add_index "members", ["payment_account_id"], name: "index_members_on_payment_account_id", unique: true, using: :btree
  add_index "members", ["phone"], name: "index_members_on_phone", unique: true, using: :btree

  create_table "members_members", force: true do |t|
    t.integer "provider_id"
    t.integer "seeker_id"
  end

  create_table "messages", force: true do |t|
    t.string   "type"
    t.integer  "provider_id"
    t.integer  "seeker_id"
    t.integer  "direction"
    t.string   "subject"
    t.text     "body"
    t.string   "reference_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "template"
  end

  add_index "messages", ["provider_id"], name: "index_messages_on_provider_id", using: :btree
  add_index "messages", ["seeker_id"], name: "index_messages_on_seeker_id", using: :btree

  create_table "providers_seekers_temp", id: false, force: true do |t|
    t.integer "provider_id"
    t.integer "seeker_id"
  end

  create_table "sitting_status_transitions", force: true do |t|
    t.integer  "sitting_id"
    t.string   "event"
    t.string   "from"
    t.string   "to"
    t.integer  "calling_member_id"
    t.datetime "created_at"
  end

  add_index "sitting_status_transitions", ["sitting_id"], name: "index_sitting_status_transitions_on_sitting_id", using: :btree

  create_table "sittings", force: true do |t|
    t.string   "type"
    t.string   "status"
    t.integer  "provider_id"
    t.integer  "seeker_id"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "date_night_slot_id"
  end

  add_index "sittings", ["date_night_slot_id"], name: "index_sittings_on_date_night_slot_id", using: :btree
  add_index "sittings", ["provider_id"], name: "index_sittings_on_provider_id", using: :btree
  add_index "sittings", ["seeker_id"], name: "index_sittings_on_seeker_id", using: :btree

  create_table "transactions", force: true do |t|
    t.integer  "seeker_id"
    t.integer  "provider_id"
    t.string   "merchant_account_id"
    t.string   "payment_token"
    t.string   "status",                      limit: 15
    t.integer  "amount_cents",                                                    default: 0,     null: false
    t.string   "amount_currency",                                                 default: "USD", null: false
    t.integer  "rate_cents",                                                      default: 0,     null: false
    t.string   "rate_currency",                                                   default: "USD", null: false
    t.datetime "started_at"
    t.decimal  "duration",                               precision: 10, scale: 4
    t.integer  "service_fee_amount_cents",                                        default: 0,     null: false
    t.string   "service_fee_amount_currency",                                     default: "USD", null: false
    t.string   "processor_transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactions", ["merchant_account_id"], name: "index_transactions_on_merchant_account_id", using: :btree
  add_index "transactions", ["payment_token"], name: "index_transactions_on_payment_token", using: :btree
  add_index "transactions", ["provider_id"], name: "index_transactions_on_provider_id", using: :btree
  add_index "transactions", ["seeker_id"], name: "index_transactions_on_seeker_id", using: :btree

end
