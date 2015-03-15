require_dependency 'application_helper'

module ApplicationHelper
  def ckeditor_javascripts
    root = RedmineCkeditor.assets_root
    javascript_tag("CKEDITOR_BASEPATH = '#{root}/ckeditor/';") +
    javascript_include_tag("application", :plugin => "redmine_ckeditor") +
    javascript_tag(RedmineCkeditor.plugins.map {|name|
      path = "#{root}/ckeditor-contrib/plugins/#{name}/"
      "CKEDITOR.plugins.addExternal('#{name}', '#{path}/');"
    }.join("\n"))
  end

  def format_activity_description_with_ckeditor(text)
    if RedmineCkeditor.enabled?
      simple_format(truncate(HTMLEntities.new.decode(strip_tags(text.to_s)), :length => 120))
    else
      format_activity_description_without_ckeditor(text)
    end
  end
  alias_method_chain :format_activity_description, :ckeditor
end
