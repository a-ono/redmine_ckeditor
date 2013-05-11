require_dependency 'rich/files_helper'

module RedmineCkeditor
  module RichFilesHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :thumb_for_file, :redmine
      end
    end

    module InstanceMethods
      def thumb_for_file_with_redmine(file)
        if file.simplified_type == "image"
          Redmine::Utils.relative_url_root + file.rich_file.url(:rich_thumb)
        else
          thumb_for_file_without_redmine(file)
        end
      end
    end
  end
end
