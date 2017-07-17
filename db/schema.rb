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

ActiveRecord::Schema.define(version: 20170717065251) do

  create_table "clean_histories", force: :cascade do |t|
    t.date     "date"
    t.string   "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clean_histories_users", id: false, force: :cascade do |t|
    t.integer "user_id",          null: false
    t.integer "clean_history_id", null: false
    t.index ["clean_history_id", "user_id"], name: "index_clean_histories_users_on_clean_history_id_and_user_id"
    t.index ["user_id", "clean_history_id"], name: "index_clean_histories_users_on_user_id_and_clean_history_id"
  end

  create_table "reveal_histories", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "seed",             limit: 8
    t.text     "scratch"
    t.integer  "clean_history_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["clean_history_id"], name: "index_reveal_histories_on_clean_history_id"
    t.index ["user_id"], name: "index_reveal_histories_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer  "sso_id"
    t.string   "account"
    t.string   "name"
    t.string   "nickname"
    t.string   "email"
    t.decimal  "ticket"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "study_state_id"
    t.index ["sso_id"], name: "index_users_on_sso_id"
    t.index ["study_state_id"], name: "index_users_on_study_state_id"
  end

end
