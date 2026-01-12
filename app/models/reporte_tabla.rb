class ReporteTabla < Prawn::Document

  def initialize(opts)
    opts.each_pair { |k, v| instance_variable_set("@#{k}", v) }
    @pdf_width = @pdf.bounds.width
    @ancho_columnas = @porcentaje_anchos.map{|porcentaje| @pdf_width * porcentaje}

    # @pdf.font "OpenSans"
    # normalizar_data
  end

  def tabla
    @pdf.table(@data, column_widths: @ancho_columnas, position: :center) do 
      cells.padding = 2
    end
  end

end