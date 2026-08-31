class Mcp::NameMatcher
  def self.call(scope:, query:, &presenter)
    records = scope.order(:nombre, :id).to_a
    normalized_query = normalize(query)
    exact_matches = records.select { |record| normalize(record.nombre) == normalized_query }

    return resolved(exact_matches.first, &presenter) if exact_matches.one?
    return ambiguous(exact_matches, &presenter) if exact_matches.many?

    suggestions = records.select { |record| suggestion?(record.nombre, normalized_query) }.first(10)
    not_found(suggestions, &presenter)
  end

  def self.normalize(value)
    I18n.transliterate(value.to_s).downcase.squish
  end
  private_class_method :normalize

  def self.suggestion?(name, normalized_query)
    normalized_name = normalize(name)
    normalized_name.include?(normalized_query) || normalized_query.include?(normalized_name)
  end
  private_class_method :suggestion?

  def self.resolved(record)
    { status: "resolved", **yield(record) }
  end
  private_class_method :resolved

  def self.ambiguous(records)
    { status: "ambiguous", matches: records.map { |record| yield(record) } }
  end
  private_class_method :ambiguous

  def self.not_found(records)
    { status: "not_found", matches: records.map { |record| yield(record) } }
  end
  private_class_method :not_found
end
