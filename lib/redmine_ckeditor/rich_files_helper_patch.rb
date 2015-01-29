require_dependency 'rich'

module Rich
  module RichFilesHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :thumb_for_file, :redmine
      end
    end

    module InstanceMethods
      def thumb_for_file_with_redmine(file)
        Redmine::Utils.relative_url_root + if file.simplified_type == "image"
          file.rich_file.url(:rich_thumb)
        else
          "/plugin_assets/redmine_ckeditor/images/document-thumb.png"
        end
      end
    end
  end
end

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    # use require_dependency if you plan to utilize development mode
    require_dependency 'rich'
    RichFile.send(:include, Rich::RichFilesHelperPatch)
  end
else
  Dispatcher.to_prepare do
    require_dependency 'rich'
    RichFile.send(:include, Rich::RichFilesHelperPatch)
  end
end