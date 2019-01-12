module RedmineCkeditor
  module Helper
    def ckeditor_javascripts
      root = RedmineCkeditor.assets_root
      javascript_tag("CKEDITOR_BASEPATH = '#{root}/ckeditor/';") +
      javascript_include_tag("application", :plugin => "redmine_ckeditor") +
      javascript_tag(RedmineCkeditor.plugins.map {|name|
        path = "#{root}/ckeditor-contrib/plugins/#{name}/"
        "CKEDITOR.plugins.addExternal('#{name}', '#{path}/');"
      }.join("\n"))
    end
  end
end
