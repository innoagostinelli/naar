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

ActiveRecord::Schema[8.1].define(version: 2026_07_13_100000) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "position"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "cities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "state_id", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id", "name"], name: "index_cities_on_state_id_and_name", unique: true
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "faqs", force: :cascade do |t|
    t.text "answer"
    t.datetime "created_at", null: false
    t.integer "position"
    t.string "question"
    t.datetime "updated_at", null: false
  end

  create_table "homepage_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "new_arrivals_eyebrow"
    t.string "new_arrivals_title"
    t.datetime "updated_at", null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "image_url"
    t.string "name", null: false
    t.integer "order_id", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "product_id"
    t.integer "qty", default: 1, null: false
    t.string "size"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.text "address"
    t.integer "city_id"
    t.string "country", default: "Venezuela", null: false
    t.datetime "created_at", null: false
    t.string "customer_name"
    t.string "customer_phone"
    t.integer "fulfillment_method"
    t.integer "state_id"
    t.integer "status", default: 0, null: false
    t.string "token"
    t.decimal "total", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_orders_on_city_id"
    t.index ["state_id"], name: "index_orders_on_state_id"
    t.index ["token"], name: "index_orders_on_token", unique: true
  end

  create_table "product_images", force: :cascade do |t|
    t.string "alt"
    t.string "color_name"
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

  create_table "states", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_states_on_name", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cities", "states"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "cities"
  add_foreign_key "orders", "states"
  add_foreign_key "product_images", "products"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "categories"
end
