class AdjuntoSerializer
  include Rails.application.routes.url_helpers

  def initialize(adjunto)
    @adjunto = adjunto
  end

  def show
    {
      id: @adjunto.id,
      filename: @adjunto.filename.to_s,
      url: rails_blob_url(@adjunto, only_path: false)
    }
  end
end
