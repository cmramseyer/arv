require "rails_helper"

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("openapi").to_s
  config.openapi_format = :yaml

  config.openapi_specs = {
    "v1/openapi.yaml" => {
      openapi: "3.0.3",
      info: {
        title: "ARV API",
        version: "v1"
      },
      servers: [
        {
          url: "http://localhost:3000",
          description: "Local development"
        }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: "JWT"
          }
        },
        schemas: {
          Error: {
            type: :object,
            additionalProperties: {
              type: :array,
              items: { type: :string }
            }
          },
          ErrorMessage: {
            type: :object,
            properties: {
              error: { type: :string }
            },
            required: %w[error]
          },
          User: {
            type: :object,
            properties: {
              id: { type: :integer },
              email: { type: :string, format: :email },
              username: { type: :string },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: %w[id email username created_at updated_at]
          },
          LoginRequest: {
            type: :object,
            properties: {
              user: {
                type: :object,
                properties: {
                  email: { type: :string, format: :email },
                  password: { type: :string, format: :password }
                },
                required: %w[email password]
              }
            },
            required: %w[user]
          },
          LoginResponse: {
            type: :object,
            properties: {
              message: { type: :string },
              user: { "$ref" => "#/components/schemas/User" },
              token: { type: :string }
            },
            required: %w[message user token]
          },
          RefreshResponse: {
            type: :object,
            properties: {
              token: { type: :string }
            },
            required: %w[token]
          },
          Estancia: {
            type: :object,
            properties: {
              id: { type: :integer },
              nombre: { type: :string, nullable: true },
              contacto: { type: :string, nullable: true },
              telefono: { type: :string, nullable: true },
              email: { type: :string, nullable: true },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: %w[id nombre contacto telefono email created_at updated_at]
          },
          EstanciaRequest: {
            type: :object,
            properties: {
              estancia: {
                type: :object,
                properties: {
                  nombre: { type: :string },
                  contacto: { type: :string, nullable: true },
                  telefono: { type: :string, nullable: true },
                  email: { type: :string, nullable: true }
                },
                required: %w[nombre]
              }
            },
            required: %w[estancia]
          },
          Cultivo: {
            type: :object,
            properties: {
              id: { type: :integer },
              nombre: { type: :string, nullable: true }
            },
            required: %w[id nombre]
          },
          CultivoRequest: {
            type: :object,
            properties: {
              cultivo: {
                type: :object,
                properties: {
                  nombre: { type: :string }
                },
                required: %w[nombre]
              }
            },
            required: %w[cultivo]
          },
          Maquinista: {
            type: :object,
            properties: {
              id: { type: :integer },
              nombre: { type: :string, nullable: true }
            },
            required: %w[id nombre]
          },
          MaquinistaRequest: {
            type: :object,
            properties: {
              maquinista: {
                type: :object,
                properties: {
                  nombre: { type: :string }
                },
                required: %w[nombre]
              }
            },
            required: %w[maquinista]
          },
          Producto: {
            type: :object,
            properties: {
              id: { type: :integer },
              nombre: { type: :string, nullable: true },
              tipo_producto: { type: :string, nullable: true },
              unidad_medida: { type: :string, enum: %w[kg gramos litros ml] },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: %w[id nombre tipo_producto unidad_medida created_at updated_at]
          },
          ProductoRequest: {
            type: :object,
            properties: {
              producto: {
                type: :object,
                properties: {
                  nombre: { type: :string },
                  tipo_producto: { type: :string },
                  unidad_medida: { type: :string, enum: %w[kg gramos litros ml] }
                },
                required: %w[nombre tipo_producto unidad_medida]
              }
            },
            required: %w[producto]
          },
          Adjunto: {
            type: :object,
            properties: {
              id: { type: :integer },
              filename: { type: :string },
              url: { type: :string }
            },
            required: %w[id filename url]
          },
          LoteAdjunto: {
            allOf: [
              { "$ref" => "#/components/schemas/Adjunto" },
              {
                type: :object,
                properties: {
                  content_type: { type: :string }
                },
                required: %w[content_type]
              }
            ]
          },
          Lote: {
            type: :object,
            properties: {
              id: { type: :integer },
              nombre: { type: :string, nullable: true },
              estancia_id: { type: :integer },
              nombre_estancia: { type: :string, nullable: true },
              lat: { type: :string, nullable: true },
              long: { type: :string, nullable: true },
              link_mapa: { type: :string, nullable: true },
              hectareas: { type: :string, nullable: true },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: %w[id nombre estancia_id nombre_estancia lat long link_mapa hectareas created_at updated_at]
          },
          LoteFull: {
            allOf: [
              { "$ref" => "#/components/schemas/Lote" },
              {
                type: :object,
                properties: {
                  adjuntos: {
                    type: :array,
                    items: { "$ref" => "#/components/schemas/LoteAdjunto" }
                  }
                },
                required: %w[adjuntos]
              }
            ]
          },
          LoteRequest: {
            type: :object,
            properties: {
              lote: {
                type: :object,
                properties: {
                  nombre: { type: :string },
                  estancia_id: { type: :integer },
                  lat: { type: :string, nullable: true },
                  long: { type: :string, nullable: true },
                  link_mapa: { type: :string, nullable: true },
                  hectareas: { type: :string, nullable: true },
                  adjuntos: {
                    type: :array,
                    items: { type: :string, format: :binary }
                  }
                },
                required: %w[nombre estancia_id]
              }
            },
            required: %w[lote]
          },
          Dosis: {
            type: :object,
            properties: {
              id: { type: :integer },
              producto_id: { type: :integer },
              cantidad: { type: :integer, nullable: true },
              lote_orden_fumigacion_id: { type: :integer, nullable: true },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: %w[id producto_id cantidad lote_orden_fumigacion_id created_at updated_at]
          },
          DosisRequest: {
            type: :object,
            properties: {
              dosis: {
                type: :object,
                properties: {
                  producto_id: { type: :integer },
                  lote_orden_fumigacion_id: { type: :integer },
                  cantidad: { type: :integer }
                },
                required: %w[producto_id lote_orden_fumigacion_id cantidad]
              }
            },
            required: %w[dosis]
          },
          OrdenDosis: {
            type: :object,
            properties: {
              id: { type: :integer },
              producto_id: { type: :integer },
              producto: { type: :string },
              cantidad: { type: :integer, nullable: true },
              unidad_medida: { type: :string, enum: %w[kg gramos litros ml] }
            },
            required: %w[id producto_id producto cantidad unidad_medida]
          },
          OrdenLote: {
            type: :object,
            properties: {
              id: { type: :integer },
              lote_id: { type: :integer },
              nombre: { type: :string },
              hectareas: { type: :string, nullable: true },
              estancia_id: { type: :integer },
              nombre_estancia: { type: :string },
              dosis: {
                type: :array,
                items: { "$ref" => "#/components/schemas/OrdenDosis" }
              }
            },
            required: %w[id lote_id nombre hectareas estancia_id nombre_estancia dosis]
          },
          OrdenFactura: {
            type: :object,
            properties: {
              nro_factura: { type: :string, nullable: true },
              nro_orden_cliente: { type: :string, nullable: true },
              fecha_factura: { type: :string, format: :date, nullable: true },
              fecha_pago: { type: :string, format: :date, nullable: true }
            },
            required: %w[nro_factura nro_orden_cliente fecha_factura fecha_pago]
          },
          OrdenFumigacion: {
            type: :object,
            properties: {
              id: { type: :integer },
              estancia_id: { type: :integer, nullable: true },
              nombre_estancia: { type: :string },
              lotes_ids: { type: :array, items: { type: :integer } },
              nombre_lote: { type: :string },
              hectareas: { type: :string, nullable: true },
              estado_orden: { type: :string, enum: %w[activa terminada] },
              lotes: { type: :array, items: { "$ref" => "#/components/schemas/OrdenLote" } },
              info_trabajo: { type: :string, nullable: true },
              fecha_trabajo: { type: :string, format: :date, nullable: true },
              fecha_trabajo_ddmmyyyy: { type: :string, nullable: true },
              datos_clima: { type: :string, nullable: true },
              sensible: { type: :boolean },
              comentarios: { type: :string, nullable: true },
              maquinista: {
                allOf: [ { "$ref" => "#/components/schemas/Maquinista" } ],
                nullable: true
              },
              creator: { type: :string, nullable: true },
              created_at: { type: :string, format: "date-time" },
              created_at_locale: { type: :string, nullable: true },
              updated_at: { type: :string, format: "date-time" },
              updated_at_locale: { type: :string, nullable: true },
              orden_url: { type: :string, nullable: true },
              orden_pdf_fecha_creacion: { type: :string, format: "date-time", nullable: true },
              orden_pdf_fecha_creacion_locale: { type: :string, nullable: true },
              cultivo: {
                allOf: [ { "$ref" => "#/components/schemas/Cultivo" } ],
                nullable: true
              },
              facturas: { type: :array, items: { "$ref" => "#/components/schemas/OrdenFactura" } },
              adjuntos: { type: :array, items: { "$ref" => "#/components/schemas/Adjunto" } }
            },
            required: %w[id estancia_id nombre_estancia lotes_ids nombre_lote hectareas estado_orden lotes info_trabajo fecha_trabajo fecha_trabajo_ddmmyyyy datos_clima sensible comentarios maquinista creator created_at created_at_locale updated_at updated_at_locale orden_url orden_pdf_fecha_creacion orden_pdf_fecha_creacion_locale cultivo facturas adjuntos]
          },
          OrdenFumigacionRequest: {
            type: :object,
            properties: {
              orden_fumigacion: {
                type: :object,
                properties: {
                  datos_clima: { type: :string, nullable: true },
                  info_trabajo: { type: :string, nullable: true },
                  sensible: { type: :boolean, nullable: true },
                  comentarios: { type: :string, nullable: true },
                  estado_orden: { type: :string, enum: %w[activa terminada], nullable: true },
                  fecha_trabajo: { type: :string, format: :date, nullable: true },
                  maquinista_id: { type: :integer, nullable: true },
                  cultivo_id: { type: :integer, nullable: true },
                  adjuntos: { type: :array, items: { type: :string, format: :binary } },
                  lotes: {
                    type: :array,
                    items: {
                      type: :object,
                      properties: {
                        id: { type: :integer, nullable: true },
                        lote_id: { type: :integer, nullable: true },
                        hectareas_reales: { type: :string, nullable: true },
                        _destroy: { type: :boolean, nullable: true },
                        dosis: {
                          type: :array,
                          items: {
                            type: :object,
                            properties: {
                              id: { type: :integer, nullable: true },
                              producto_id: { type: :integer },
                              cantidad: { type: :integer },
                              _destroy: { type: :boolean, nullable: true }
                            },
                            required: %w[producto_id cantidad]
                          }
                        }
                      }
                    }
                  }
                }
              }
            },
            required: %w[orden_fumigacion]
          },
          TerminarOrdenFumigacionRequest: {
            type: :object,
            properties: {
              orden_fumigacion: {
                type: :object,
                properties: {
                  datos_clima: { type: :string, nullable: true },
                  info_trabajo: { type: :string, nullable: true },
                  fecha_trabajo: { type: :string, format: :date, nullable: true },
                  maquinista_id: { type: :integer, nullable: true }
                }
              }
            },
            required: %w[orden_fumigacion]
          },
          OrdenPdfResponse: {
            type: :object,
            properties: {
              orden_url: { type: :string },
              orden_pdf_fecha_creacion: { type: :string, format: "date-time" },
              orden_pdf_fecha_creacion_locale: { type: :string },
              message: { type: :string }
            },
            required: %w[orden_url orden_pdf_fecha_creacion orden_pdf_fecha_creacion_locale message]
          },
          PendienteFacturaLote: {
            type: :object,
            properties: {
              lote_id: { type: :integer },
              hectareas: { type: :string, nullable: true },
              fecha_trabajo: { type: :string, format: :date, nullable: true },
              fecha_trabajo_ddmmyyyy: { type: :string, nullable: true },
              maquinista: { type: :string, nullable: true },
              orden_id: { type: :integer }
            },
            required: %w[lote_id hectareas fecha_trabajo fecha_trabajo_ddmmyyyy maquinista orden_id]
          },
          PendienteFacturaEstancia: {
            type: :object,
            properties: {
              id: { type: :integer },
              nombre: { type: :string },
              data: { type: :array, items: { "$ref" => "#/components/schemas/PendienteFacturaLote" } }
            },
            required: %w[id nombre data]
          },
          Factura: {
            type: :object,
            properties: {
              id: { type: :integer },
              fecha_factura: { type: :string, format: :date, nullable: true },
              fecha_pago: { type: :string, format: :date, nullable: true },
              nro_factura: { type: :string, nullable: true },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: %w[id fecha_factura fecha_pago nro_factura created_at updated_at]
          },
          FacturaRequest: {
            type: :object,
            properties: {
              nro_factura: { type: :string, nullable: true },
              ordenes_fumigacion: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    importe: { type: :string, nullable: true },
                    nro_orden_cliente: { type: :string, nullable: true }
                  },
                  required: %w[id]
                }
              }
            },
            required: %w[ordenes_fumigacion]
          },
          FacturaUpdateRequest: {
            type: :object,
            properties: {
              fecha_pago: { type: :string, format: :date }
            },
            required: %w[fecha_pago]
          },
          FacturaPagoOrden: {
            type: :object,
            properties: {
              id: { type: :integer },
              importe: { type: :string },
              nro_orden_cliente: { type: :string, nullable: true },
              nombre_estancia: { type: :string },
              lotes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    nombre: { type: :string },
                    hectareas: { type: :string, nullable: true }
                  },
                  required: %w[nombre hectareas]
                }
              }
            },
            required: %w[id importe nro_orden_cliente nombre_estancia lotes]
          },
          FacturaPago: {
            type: :object,
            properties: {
              id: { type: :integer },
              fecha_factura: { type: :string, format: :date },
              fecha_factura_ddmmyyyy: { type: :string },
              nro_factura: { type: :string, nullable: true },
              ordenes_fumigacion: { type: :array, items: { "$ref" => "#/components/schemas/FacturaPagoOrden" } }
            },
            required: %w[id fecha_factura fecha_factura_ddmmyyyy nro_factura ordenes_fumigacion]
          },
          Estadistica: {
            type: :object,
            properties: {
              hectareas_por_propietario: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    nombre_estancia: { type: :string },
                    hectareas: { type: :string }
                  },
                  required: %w[nombre_estancia hectareas]
                }
              },
              hectareas_por_maquinista: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    maquinista: { type: :string },
                    hectareas: { type: :string }
                  },
                  required: %w[maquinista hectareas]
                }
              },
              hectareas_por_cultivo: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    cultivo: { type: :string },
                    hectareas: { type: :string }
                  },
                  required: %w[cultivo hectareas]
                }
              }
            },
            required: %w[hectareas_por_propietario hectareas_por_maquinista hectareas_por_cultivo]
          }
        }
      },
      security: [
        { bearerAuth: [] }
      ],
      paths: {}
    }
  }
end
