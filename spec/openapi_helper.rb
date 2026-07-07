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
        schemas: {}
      },
      security: [
        { bearerAuth: [] }
      ],
      paths: {}
    }
  }
end
