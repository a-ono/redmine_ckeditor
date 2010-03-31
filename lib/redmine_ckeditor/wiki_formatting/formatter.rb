module RedmineCkeditor::WikiFormatting
  class Formatter
    def initialize(text)
      @text = text
    end

    def to_html(&block)
      ActionView::Base.white_list_sanitizer.sanitize @text,
        :tags => RedmineCkeditor::ALLOWED_TAGS,
        :attributes => RedmineCkeditor::ALLOWED_ATTRIBUTES
    end
  end
end
