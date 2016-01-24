module ClientsHelper
  def sortable (column, title = nil)
    puts params
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, params.merge({:sort => column, :direction => direction}), {:class => css_class}
  end

  def editor_image(content, img, email=false)
    render(
      '/clients/email/full/templates/image_upload',
      content: content,
      img_name: img,
      exist: content.data.any? && content.data[img].present?,
      email: email
    )
  end

  def editor_text(content, txt, email=false)
    render(
      '/clients/email/full/templates/text_edit',
      content: content,
      txt_name: txt,
      email: email
      )
  end

end
