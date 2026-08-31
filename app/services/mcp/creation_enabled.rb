class Mcp::CreationEnabled
  def self.call
    ENV["ALLOW_CREATION"] == "true"
  end
end
