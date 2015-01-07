require 'rake'

module RedmineCkeditor
  class RichAssetsGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    desc "Generate rich asset files for Redmine"
    def create_assets
      rake "redmine_ckeditor:assets:precompile"

      gsub_file RedmineCkeditor.root.join("assets/ckeditor-contrib/plugins/richfile/plugin.js"),
        "/assets/rich/", "../images/"

      application_js = RedmineCkeditor.root.join("assets/javascripts/application.js")
      browser_js = RedmineCkeditor.root.join("assets/javascripts/browser.js")

      gsub_file browser_js, "opt=opt.split(',');", "opt=opt ? opt.split(',') : [];"

      gsub_file application_js, /var CKEDITOR_BASEPATH.+$/, ""

      gsub_file application_js, /CKEDITOR.plugins.addExternal.+$/, ""

      gsub_file browser_js, '"/rich/files/"+', ""

      inject_into_file browser_js,
        "\t\turl = $(item).data('relative-url-root') + url;\n",
        :after => "data('uris')[this._options.currentStyle];\n"

      gsub_file RedmineCkeditor.root.join("assets/stylesheets/application.css"),
        'image-url("rich/', 'url("../images/'

      append_to_file RedmineCkeditor.root.join("assets/stylesheets/editor.css"),
        "\nhtml, body {\n  height: 100%;\n}\n"
    end
  end
end
