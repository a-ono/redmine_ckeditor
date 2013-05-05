require_dependency 'application_helper'

module RedmineCkeditor
  module ApplicationHelperPatch
    def self.included(base)
      base.class_eval do
        unloadable
        def ckeditor_javascripts
          javascript_include_tag("application", :plugin => "redmine_ckeditor") +
          javascript_tag(RedmineCkeditor.plugins.map {|name|
            "CKEDITOR.plugins.addExternal('#{name}', '/plugin_assets/redmine_ckeditor/ckeditor-contrib/plugins/#{name}/');"
          }.join("\n"))
        end
      end
    end
  end
end
