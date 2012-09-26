module RedmineCkeditor::WikiFormatting
  module Helper
    def replace_editor(field_id)
      javascript_tag <<-EOT
      $(document).ready(function() {
        CKEDITOR.config.contentsCss = "#{stylesheet_path "application"}";
        CKEDITOR.config.bodyClass = "wiki";
        CKEDITOR.config.toolbar = #{RedmineCkeditorSetting.toolbar.inspect};
        CKEDITOR.config.language = "#{current_language.to_s.downcase}";

        var textarea = $('##{field_id}');
        textarea.parent().before($('<br/>'));
        var editor = CKEDITOR.replace(textarea.get(0), {
          on: {
            instanceReady : function(ev) {
              var writer = this.dataProcessor.writer;
              $.each(['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'li'],
                function() {
                  writer.setRules(this, { breakAfterOpen : false });
                }
              );
            }
          }
        });
        $(":submit").siblings("a").each(function() {
          var a = $(this);
          if (a.attr("onclick").indexOf("preview") >= 0) a.hide();
        });

        // fire change event
        setInterval(function(){textarea.val(editor.getData());}, 1000);
      });
      EOT
    end

    def overwrite_functions
      javascript_tag <<-EOT
        function showAndScrollTo(id, focus) {
          var elem = $("#" + id);
          elem.show();
          if (focus != null) CKEDITOR.instances[focus].focus();
          $('html, body').animate({scrollTop: elem.offset().top}, 100);
        }
      EOT
    end

    def wikitoolbar_for(field_id)
      javascript_include_tag('ckeditor/ckeditor', :plugin => 'redmine_ckeditor') +
        replace_editor(field_id) + overwrite_functions
    end

    def initial_page_content(page)
      "<h1>#{ERB::Util.html_escape page.pretty_title}</h1>"
    end

    def heads_for_wiki_formatter
    end
  end
end
