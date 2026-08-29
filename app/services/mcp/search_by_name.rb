class Mcp::SearchByName
  def self.call(scope:, query:, limit:)
    scope
      .where("LOWER(nombre) LIKE ? ESCAPE '\\'", search_pattern(query))
      .order(:nombre, :id)
      .limit(limit)
  end

  def self.search_pattern(query)
    "%#{ActiveRecord::Base.sanitize_sql_like(query.strip.downcase)}%"
  end
  private_class_method :search_pattern
end
