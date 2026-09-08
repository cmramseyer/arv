configured_origins = ENV.fetch("CORS_ORIGINS", Rails.application.credentials.cors_origins.to_s)
cors_origins = configured_origins.split(",").map(&:strip).reject(&:empty?)

valid_origin = lambda do |origin|
  uri = URI.parse(origin)
  uri.is_a?(URI::HTTP) && uri.host.present? && uri.path.empty? && uri.query.nil? &&
    uri.fragment.nil? && uri.userinfo.nil? && !uri.host.include?("*")
rescue URI::InvalidURIError
  false
end

unless cors_origins.any? && cors_origins.all?(&valid_origin)
  raise "CORS_ORIGINS must contain one or more exact HTTP(S) origins"
end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*cors_origins)

    resource "*",
      headers: :any,
      credentials: true,
      methods: [ :get, :post, :patch, :put, :delete, :options, :head ]
  end
end
