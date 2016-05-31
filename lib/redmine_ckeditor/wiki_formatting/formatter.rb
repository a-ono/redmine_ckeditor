module RedmineCkeditor::WikiFormatting
  class Formatter
    include Redmine::WikiFormatting::LinksHelper

    def initialize(text)
      @text = text
    end

    def to_html(&block)
      preserved = []
      text = @text.gsub(/<pre>\s*(.*?)\s*<\/pre>/m) {|m|
        content = if matched = $1.match(/<code\s+class="(\w+)">[\r\n]*(.*?)[\r\n]*<\/code>/m)
          lang, code = matched.captures
          code = Redmine::SyntaxHighlighting.highlight_by_language(code, lang)
          %Q[<pre>\n<code class="#{lang} syntaxhl">#{code}</code>\n</pre>]
        else
          m
        end
        preserved.push(content)
        "____preserved_#{preserved.size}____"
      }.gsub(/{{.*?}}/m) {|m|
        preserved.push(m)
        "____preserved_#{preserved.size}____"
      }

      auto_link!(text)
      text = ActionView::Base.white_list_sanitizer.sanitize(text,
        :tags => RedmineCkeditor.allowed_tags,
        :attributes => RedmineCkeditor.allowed_attributes
      )

      preserved.each.with_index(1) {|content, i|
        text.gsub!("____preserved_#{i}____", content)
      }
      text
    end
  end
end
