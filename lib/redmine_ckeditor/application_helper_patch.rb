require_dependency 'application_helper'

module ApplicationHelper
  def ckeditor_javascripts
    javascript_include_tag("application", :plugin => "redmine_ckeditor") +
    javascript_tag(RedmineCkeditor.plugins.map {|name|
      "CKEDITOR.plugins.addExternal('#{name}', '/plugin_assets/redmine_ckeditor/ckeditor-contrib/plugins/#{name}/');"
    }.join("\n"))
  end
end
