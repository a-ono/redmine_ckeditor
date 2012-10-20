module RedmineCkeditor::WikiFormatting
  module Helper
    def replace_editor(field_id)
      javascript_tag <<-EOT
      $(document).ready(function() {
        $(":submit").siblings("a").each(function() {
          var a = $(this);
          if (a.attr("onclick").indexOf("preview") >= 0) a.hide();
        });

        var id = '#{field_id}';
        var textarea = document.getElementById(id);
        if (!textarea) return;

        var editor = CKEDITOR.replace(textarea, {
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

        // fire change event
        RedmineCkeditor.intervalId[id] =
          setInterval(function(){ textarea.value = editor.getData(); }, 1000);
      });
      EOT
    end

    def set_config
      javascript_tag <<-EOT
        CKEDITOR.config.contentsCss = "#{stylesheet_path "application"}";
        CKEDITOR.config.bodyClass = "wiki";
        CKEDITOR.config.toolbar = #{RedmineCkeditorSetting.toolbar.inspect};
        CKEDITOR.config.language = "#{current_language.to_s.downcase}";

        var RedmineCkeditor = {
          intervalId: {}
        };
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

        function destroyEditor(id) {
          clearInterval(RedmineCkeditor.intervalId[id])
          if (CKEDITOR.instances[id]) CKEDITOR.instances[id].destroy();
        }
      EOT
    end

    def initial_setup
      javascript_include_tag('ckeditor/ckeditor', :plugin => 'redmine_ckeditor') + set_config + overwrite_functions
    end

    def wikitoolbar_for(field_id)
      if params[:format] == "js"
        replace_editor(field_id)
      else
        initial_setup + replace_editor(field_id)
      end
    end

    def initial_page_content(page)
      "<h1>#{ERB::Util.html_escape page.pretty_title}</h1>"
    end

    def heads_for_wiki_formatter
    end
  end
end
