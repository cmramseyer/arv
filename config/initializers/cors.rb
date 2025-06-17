Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins Rails.application.credentials.cors_origins

    resource '*',
      headers: :any,
      expose: ['Authorization'],
      methods: [:get, :post, :patch, :put, :delete, :options, :head]
  end
end