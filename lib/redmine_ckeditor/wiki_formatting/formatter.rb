module RedmineCkeditor::WikiFormatting
  class Formatter
    def initialize(text)
      @text = text
    end

    def to_html(&block)
      ActionView::Base.white_list_sanitizer.sanitize(@text,
        :tags => RedmineCkeditor::ALLOWED_TAGS,
        :attributes => RedmineCkeditor::ALLOWED_ATTRIBUTES
      ).gsub(/<pre>\s*<code\s+(?:class="(\w+)")>[\r\n]*([^<]*?)[\r\n]*<\/code>\s*<\/pre>/) {
        lang, code = $~.captures
        %Q[<pre>\n<code class="#{lang} syntaxhl">#{
          Redmine::SyntaxHighlighting.highlight_by_language(code, lang)
        }</code>\n</pre>]
      }
    end
  end
end
