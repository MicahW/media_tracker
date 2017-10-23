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

ActiveRecord::Schema.define(version: 20171023205636) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "annotations", force: :cascade do |t|
    t.string "name", null: false
    t.string "keywords", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "belongs", force: :cascade do |t|
    t.string "parents_guid", null: false
    t.string "childs_guid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["childs_guid"], name: "index_belongs_on_childs_guid"
    t.index ["parents_guid"], name: "index_belongs_on_parents_guid"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categorizes", force: :cascade do |t|
    t.bigint "categories_id"
    t.string "dagrs_guid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["categories_id"], name: "index_categorizes_on_categories_id"
    t.index ["dagrs_guid"], name: "index_categorizes_on_dagrs_guid"
  end

  create_table "dagrs", primary_key: "guid", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.string "storage_path", null: false
    t.string "creator_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_dagrs_on_name"
    t.index ["storage_path"], name: "index_dagrs_on_storage_path"
  end

  create_table "has_categories", force: :cascade do |t|
    t.bigint "users_id"
    t.bigint "categories_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["categories_id"], name: "index_has_categories_on_categories_id"
    t.index ["users_id"], name: "index_has_categories_on_users_id"
  end

  create_table "has_dagrs", force: :cascade do |t|
    t.bigint "users_id"
    t.string "dagrs_guid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["users_id"], name: "index_has_dagrs_on_users_id"
  end

  create_table "sub_categories", force: :cascade do |t|
    t.integer "parents_id", null: false
    t.integer "childs_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_descriptions", force: :cascade do |t|
    t.bigint "user_id"
    t.string "dagrs_guid", null: false
    t.bigint "annotations_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["annotations_id"], name: "index_user_descriptions_on_annotations_id"
    t.index ["dagrs_guid"], name: "index_user_descriptions_on_dagrs_guid"
    t.index ["user_id"], name: "index_user_descriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "belongs", "dagrs", column: "childs_guid", primary_key: "guid", name: "belongs_childs_guid_fkey"
  add_foreign_key "belongs", "dagrs", column: "parents_guid", primary_key: "guid", name: "belongs_parents_guid_fkey"
  add_foreign_key "categorizes", "categories", column: "categories_id"
  add_foreign_key "categorizes", "dagrs", column: "dagrs_guid", primary_key: "guid", name: "categorizes_dagrs_guid_fkey"
  add_foreign_key "has_categories", "categories", column: "categories_id"
  add_foreign_key "has_categories", "users", column: "users_id"
  add_foreign_key "has_dagrs", "dagrs", column: "dagrs_guid", primary_key: "guid", name: "has_dagrs_dagrs_guid_fkey"
  add_foreign_key "has_dagrs", "users", column: "users_id"
  add_foreign_key "sub_categories", "categories", column: "childs_id", name: "sub_categories_childs_id_fkey"
  add_foreign_key "sub_categories", "categories", column: "parents_id", name: "sub_categories_parents_id_fkey"
  add_foreign_key "user_descriptions", "annotations", column: "annotations_id"
  add_foreign_key "user_descriptions", "dagrs", column: "dagrs_guid", primary_key: "guid", name: "user_descriptions_dagrs_guid_fkey"
  add_foreign_key "user_descriptions", "users"
end
