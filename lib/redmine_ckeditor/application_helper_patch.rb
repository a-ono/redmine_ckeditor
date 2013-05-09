require_dependency 'application_helper'

module ApplicationHelper
  def ckeditor_javascripts
    assets_root = "#{Redmine::Utils.relative_url_root}/plugin_assets/redmine_ckeditor"
    javascript_tag("CKEDITOR_BASEPATH = '#{assets_root}/ckeditor/';") +
    javascript_include_tag("application", :plugin => "redmine_ckeditor") +
    javascript_tag(RedmineCkeditor.plugins.map {|name|
      path = "#{assets_root}/ckeditor-contrib/plugins/#{name}/"
      "CKEDITOR.plugins.addExternal('#{name}', '#{path}/');"
    }.join("\n"))
  end
end
