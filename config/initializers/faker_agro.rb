module Faker
  class Agro < Faker::Base
    @adjetivos = %w[Super Ultra Max Nitro Bio Eco Pro]
    @nombres   = %w[Glicofol Glyphosate Atrazina Clorox Tordon Lambda]
    @formas    = %w[WG SC EC SL WP DF]

    class << self
      def producto
        "#{@adjetivos.sample} #{@nombres.sample} #{@formas.sample}"
      end
    end
  end
end
