# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_12_003400) do
  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "position"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "faqs", force: :cascade do |t|
    t.text "answer"
    t.datetime "created_at", null: false
    t.integer "position"
    t.string "question"
    t.datetime "updated_at", null: false
  end

  create_table "product_images", force: :cascade do |t|
    t.string "alt"
    t.datetime "created_at", null: false
    t.integer "position"
    t.integer "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.string "color_hex"
    t.string "color_name"
    t.datetime "created_at", null: false
    t.integer "product_id", null: false
    t.string "size"
    t.string "sku"
    t.integer "stock"
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_variants_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.integer "category_id", null: false
    t.decimal "compare_at_price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "flag"
    t.string "name"
    t.integer "position"
    t.decimal "price", precision: 10, scale: 2
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
  end

  create_table "reels", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "label"
    t.integer "position"
    t.string "tag"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "product_images", "products"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "categories"
end
