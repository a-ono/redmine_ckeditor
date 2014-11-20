module RedmineCkeditor::WikiFormatting
  class Formatter
    AUTO_LINK_RE = const_defined?(:AUTO_LINK_RE) ? :AUTO_LINK_RE : Redmine::WikiFormatting::LinksHelper::AUTO_LINK_RE

    def initialize(text)
      @text = text
    end

    def to_html(&block)
      auto_link!(@text)
      ActionView::Base.white_list_sanitizer.sanitize(@text,
        :tags => RedmineCkeditor.allowed_tags,
        :attributes => RedmineCkeditor.allowed_attributes
      ).gsub(/<pre>\s*<code\s+(?:class="(\w+)")>[\r\n]*([^<]*?)[\r\n]*<\/code>\s*<\/pre>/) {
        lang, code = $~.captures
        %Q[<pre>\n<code class="#{lang} syntaxhl">#{
          Redmine::SyntaxHighlighting.highlight_by_language(code, lang)
        }</code>\n</pre>]
      }.gsub(/\{\{(.*?)\}\}/) {
        "{{" + CGI.unescapeHTML($1) + "}}"
      }
    end

    def auto_link!(text)
      text.gsub!(AUTO_LINK_RE) do
        all, leading, proto, url, post = $&, $1, $2, $3, $6
        if leading =~ /<a\s/i || leading =~ /![<>=]?/
          # don't replace URLs that are already linked
          # and URLs prefixed with ! !> !< != (textile images)
          all
        else
          # Idea below : an URL with unbalanced parenthesis and
          # ending by ')' is put into external parenthesis
          if ( url[-1]==?) and ((url.count("(") - url.count(")")) < 0 ) )
            url=url[0..-2] # discard closing parenthesis from url
            post = ")"+post # add closing parenthesis to post
          end
          content = proto + url
          href = "#{proto=="www."?"http://www.":proto}#{url}"
          %(#{leading}<a class="external" href="#{href}">#{content}</a>#{post}).html_safe
        end
      end
    end
  end
end
