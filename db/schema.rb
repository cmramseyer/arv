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

ActiveRecord::Schema[8.0].define(version: 2026_07_27_120000) do
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
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cultivos", force: :cascade do |t|
    t.string "nombre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dosis", force: :cascade do |t|
    t.integer "producto_id", null: false
    t.integer "cantidad"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lote_orden_fumigacion_id"
    t.index ["lote_orden_fumigacion_id"], name: "index_dosis_on_lote_orden_fumigacion_id"
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

  create_table "facturas", force: :cascade do |t|
    t.date "fecha_factura"
    t.date "fecha_pago"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nro_factura"
  end

  create_table "facturas_ordenes_fumigacion", force: :cascade do |t|
    t.integer "factura_id", null: false
    t.integer "orden_fumigacion_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "importe", precision: 10, scale: 2, default: "0.0", null: false
    t.string "nro_orden_cliente"
    t.index ["factura_id"], name: "index_facturas_ordenes_fumigacion_on_factura_id"
    t.index ["orden_fumigacion_id"], name: "index_facturas_ordenes_fumigacion_on_orden_fumigacion_id", unique: true
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "lote_ordenes_fumigacion", force: :cascade do |t|
    t.integer "lote_id"
    t.integer "orden_fumigacion_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "hectareas_reales", precision: 10, scale: 2
    t.string "nombre_manual"
    t.index ["lote_id"], name: "index_lote_ordenes_fumigacion_on_lote_id"
    t.index ["orden_fumigacion_id"], name: "index_lote_ordenes_fumigacion_on_orden_fumigacion_id"
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

  create_table "maquinistas", force: :cascade do |t|
    t.string "nombre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ordenes_fumigacion", force: :cascade do |t|
    t.text "datos_clima"
    t.text "info_trabajo"
    t.integer "estado_orden", default: 0, null: false
    t.date "fecha_trabajo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id", null: false
    t.integer "maquinista_id"
    t.integer "cultivo_id"
    t.boolean "sensible", default: false
    t.text "comentarios"
    t.integer "estancia_id", null: false
    t.index ["creator_id"], name: "index_ordenes_fumigacion_on_creator_id"
    t.index ["cultivo_id"], name: "index_ordenes_fumigacion_on_cultivo_id"
    t.index ["estancia_id"], name: "index_ordenes_fumigacion_on_estancia_id"
    t.index ["maquinista_id"], name: "index_ordenes_fumigacion_on_maquinista_id"
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
    t.string "username", null: false
    t.string "refresh_token_digest"
    t.datetime "refresh_token_expires_at"
    t.string "refresh_token_jti"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["refresh_token_digest"], name: "index_users_on_refresh_token_digest"
    t.index ["refresh_token_jti"], name: "index_users_on_refresh_token_jti"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "dosis", "lote_ordenes_fumigacion"
  add_foreign_key "dosis", "productos"
  add_foreign_key "facturas_ordenes_fumigacion", "facturas"
  add_foreign_key "facturas_ordenes_fumigacion", "ordenes_fumigacion"
  add_foreign_key "lote_ordenes_fumigacion", "lotes"
  add_foreign_key "lote_ordenes_fumigacion", "ordenes_fumigacion"
  add_foreign_key "lotes", "estancias"
  add_foreign_key "ordenes_fumigacion", "cultivos"
  add_foreign_key "ordenes_fumigacion", "estancias"
  add_foreign_key "ordenes_fumigacion", "maquinistas"
  add_foreign_key "ordenes_fumigacion", "users", column: "creator_id"
end
