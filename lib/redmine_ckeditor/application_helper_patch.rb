require_dependency 'application_helper'

module RedmineCkeditor
  module ApplicationHelperPatch
    def ckeditor_javascripts
      root = RedmineCkeditor.assets_root
      javascript_tag("CKEDITOR_BASEPATH = '#{root}/ckeditor/';") +
      javascript_include_tag("application", :plugin => "redmine_ckeditor") +
      javascript_tag(RedmineCkeditor.plugins.map {|name|
        path = "#{root}/ckeditor-contrib/plugins/#{name}/"
        "CKEDITOR.plugins.addExternal('#{name}', '#{path}/');"
      }.join("\n"))
    end

    def format_activity_description(text)
      if RedmineCkeditor.enabled?
        simple_format(truncate(HTMLEntities.new.decode(strip_tags(text.to_s)), :length => 120))
      else
        super
      end
    end
  end
end

ApplicationHelper.prepend RedmineCkeditor::ApplicationHelperPatch
