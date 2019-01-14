module RedmineCkeditor
  module Helper
    def ckeditor_javascripts
      root = RedmineCkeditor.assets_root
      plugin_script = RedmineCkeditor.plugins.map {|name|
        "CKEDITOR.plugins.addExternal('#{name}', '#{root}/ckeditor-contrib/plugins/#{name}/');"
      }.join

      javascript_tag("CKEDITOR_BASEPATH = '#{root}/ckeditor/';") +
      javascript_include_tag("application", :plugin => "redmine_ckeditor") +
      javascript_tag(<<-EOT)
        #{plugin_script}

        CKEDITOR.on("instanceReady", function(event) {
          var editor = event.editor;
          var textarea = document.getElementById(editor.name);
          editor.on("change", function() {
            textarea.value = editor.getSnapshot();
          });
        });

        $(window).on("beforeunload", function() {
          for (var id in CKEDITOR.instances) {
            if (CKEDITOR.instances[id].checkDirty()) {
              return #{l(:text_warn_on_leaving_unsaved).inspect};
            }
          }
        });
        $(document).on("submit", "form", function() {
          for (var id in CKEDITOR.instances) {
            CKEDITOR.instances[id].resetDirty();
          }
        });
      EOT
    end
  end
end
