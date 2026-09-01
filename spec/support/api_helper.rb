module ApiHelper
  def authenticated_header(user)
    sign_in user
    {}
  end

  # Rswag resolves apiKey header schemes through a method named after the header.
  define_method("X-CSRF-Token") { "test-csrf-token" }
end
