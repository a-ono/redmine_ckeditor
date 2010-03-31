module RedmineCkeditor::WikiFormatting
  module Helper
    def replace_editor(field_id)
      javascript_tag <<-EOT
      (function() {
        CKEDITOR.config.contentsCss = "#{stylesheet_path "application"}";
        CKEDITOR.config.bodyClass = "wiki";
        CKEDITOR.config.toolbar = #{RedmineCkeditorSetting.toolbar.inspect};

        var textarea = $('#{field_id}');
        Event.observe(document, "dom:loaded", function() {
          var editor = CKEDITOR.replace(textarea);
          var submit = Form.getInputs(textarea.form, "submit").first();
          if (submit) {
            submit.nextSiblings().each(function(elem) {
              if (elem.nodeName.toLowerCase() != "a") return;
              if (elem.onclick.toString().match(/Ajax.Updater.+preview/)){
                Element.hide(elem);
                return $break;
              }
            });
          }
        }, false);
      })();
      EOT
    end

    def overwrite_functions
      javascript_tag <<-EOT
        function showAndScrollTo(id, focus) {
          Element.show(id);
          Element.scrollTo(id);
          if (focus != null) Form.Element.focus(CKEDITOR.instances[focus]);
        }
      EOT
    end

    def wikitoolbar_for(field_id)
      javascript_include_tag(Redmine::Utils.relative_url_root +
        '/plugin_assets/redmine_ckeditor/javascripts/ckeditor/ckeditor') +
        replace_editor(field_id) +
        overwrite_functions
    end

    def initial_page_content(page)
      "<h1>#{ERB::Util.html_escape page.pretty_title}</h1>"
    end

    def heads_for_wiki_formatter
    end
  end
end
