module ApplicationHelper
  include Pagy::Frontend
  def render_flash_stream
    turbo_stream.update "flash", partial: "layouts/flash"
  end
end
