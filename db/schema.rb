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

ActiveRecord::Schema[8.0].define(version: 2025_04_18_204228) do
  create_table "dosis", force: :cascade do |t|
    t.integer "producto_id", null: false
    t.integer "orden_fumigacion_id", null: false
    t.integer "cantidad"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["orden_fumigacion_id"], name: "index_dosis_on_orden_fumigacion_id"
    t.index ["producto_id"], name: "index_dosis_on_producto_id"
  end

  create_table "estancias", force: :cascade do |t|
    t.string "nombre"
    t.string "contacto"
    t.string "telefono"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "lotes", force: :cascade do |t|
    t.string "nombre"
    t.decimal "lat", precision: 10, scale: 8
    t.decimal "long", precision: 10, scale: 8
    t.string "link_mapa"
    t.decimal "hectareas", precision: 10, scale: 2
    t.integer "estancia_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estancia_id"], name: "index_lotes_on_estancia_id"
  end

  create_table "ordenes_fumigacion", force: :cascade do |t|
    t.integer "lote_id", null: false
    t.text "datos_clima"
    t.text "info_trabajo"
    t.string "creado_por"
    t.integer "estado_orden", default: 0, null: false
    t.date "fecha_trabajo"
    t.string "maquinista"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lote_id"], name: "index_ordenes_fumigacion_on_lote_id"
  end

  create_table "productos", force: :cascade do |t|
    t.string "nombre"
    t.string "tipo_producto"
    t.integer "unidad_medida", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "dosis", "ordenes_fumigacion"
  add_foreign_key "dosis", "productos"
  add_foreign_key "lotes", "estancias"
  add_foreign_key "ordenes_fumigacion", "lotes"
end
