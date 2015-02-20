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

ActiveRecord::Schema.define(version: 20150218190113) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ingredients", force: :cascade do |t|
    t.string   "name"
    t.float    "quantity"
    t.string   "quantity_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "polyscope_edges", force: :cascade do |t|
    t.integer "abstract_id",    null: false
    t.string  "abstract_type",  null: false
    t.integer "component_id",   null: false
    t.string  "component_type", null: false
  end

  add_index "polyscope_edges", ["abstract_id", "abstract_type"], name: "a_abstract", using: :btree
  add_index "polyscope_edges", ["component_id", "component_type"], name: "a_component", using: :btree

  create_table "recipes", force: :cascade do |t|
    t.string   "title"
    t.integer  "prep_time"
    t.integer  "cook_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shapers", force: :cascade do |t|
    t.text    "diffs"
    t.integer "shape_id",   null: false
    t.string  "shape_type", null: false
  end

  add_index "shapers", ["shape_id", "shape_type"], name: "index_shapers_on_shape_id_and_shape_type", using: :btree

  create_table "steps", force: :cascade do |t|
    t.text     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
