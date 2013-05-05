module RedmineCkeditor::WikiFormatting
  class Formatter
    def initialize(text)
      @text = text
    end

    def to_html(&block)
      # If there are comments in the textile format, then format those as textile still for
      # backwards compatibility.
      # This is determined by whether the text is wrapped in a <p> tag.
      if @text.match(/<p>.*<\/p>/).nil?
        textile_formatter = Redmine::WikiFormatting::Textile::Formatter.new(@text)
        textile_formatter.to_html
      else
        ActionView::Base.white_list_sanitizer.sanitize @text,
          :tags => RedmineCkeditor::ALLOWED_TAGS,
          :attributes => RedmineCkeditor::ALLOWED_ATTRIBUTES
      end
    end
  end
end
