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

ActiveRecord::Schema.define(version: 2022_08_30_193724) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "trip_id", null: false
    t.bigint "hotel_id", null: false
    t.bigint "flight_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["flight_id"], name: "index_bookings_on_flight_id"
    t.index ["hotel_id"], name: "index_bookings_on_hotel_id"
    t.index ["trip_id"], name: "index_bookings_on_trip_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "destinations", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.bigint "country_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["country_id"], name: "index_destinations_on_country_id"
  end

  create_table "flights", force: :cascade do |t|
    t.string "reservation_number"
    t.date "departure_departure"
    t.string "airport_departure_departure"
    t.date "departure_arrival"
    t.string "airport_departure_arrival"
    t.string "departure_airline"
    t.date "return_departure"
    t.string "airport_return_departure"
    t.date "return_arrival"
    t.string "airport_return_arrival"
    t.string "return_airline"
    t.float "price"
    t.string "currency"
    t.bigint "trip_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["trip_id"], name: "index_flights_on_trip_id"
  end

  create_table "hotels", force: :cascade do |t|
    t.string "name"
    t.date "check_in"
    t.date "check_out"
    t.float "price"
    t.bigint "trip_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "currency"
    t.string "category"
    t.string "zone_name"
    t.float "rate"
    t.integer "reviewCount"
    t.float "latitude"
    t.float "longitude"
    t.index ["trip_id"], name: "index_hotels_on_trip_id"
  end

  create_table "trips", force: :cascade do |t|
    t.string "location"
    t.string "destination"
    t.date "start_date"
    t.date "end_date"
    t.integer "adults"
    t.float "budget"
    t.integer "pflight", default: 30
    t.integer "photel", default: 40
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.string "name"
    t.integer "rooms"
    t.float "budgetHotel"
    t.float "budgetFlight"
    t.string "budgetCurrency"
    t.index ["user_id"], name: "index_trips_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookings", "flights"
  add_foreign_key "bookings", "hotels"
  add_foreign_key "bookings", "trips"
  add_foreign_key "destinations", "countries"
  add_foreign_key "flights", "trips"
  add_foreign_key "hotels", "trips"
  add_foreign_key "trips", "users"
end
