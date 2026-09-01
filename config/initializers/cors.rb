frontend_origin = Rails.application.credentials.cors_origins.to_s
unless frontend_origin.match?(%r{\Ahttps?://[^/]+\z}) && frontend_origin != "*"
  raise "cors_origins must be one exact HTTP(S) origin"
end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins frontend_origin

    resource "*",
      headers: :any,
      credentials: true,
      methods: [ :get, :post, :patch, :put, :delete, :options, :head ]
  end
end
