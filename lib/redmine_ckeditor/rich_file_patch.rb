require_dependency 'rich'

module Rich
  module RichFilePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        has_attached_file :rich_file,
          :styles => Proc.new {|a| a.instance.set_styles },
          :convert_options => Proc.new { |a| Rich.convert_options[a] },
          :restricted_characters => /[&$+,\/:;=?@<>\[\]\{\}\|\\\^~#]/

        alias_method_chain :clean_file_name, :ckeditor
      end
    end

    module InstanceMethods
      def clean_file_name_with_ckeditor
        name = CGI::unescape(rich_file_file_name)
        self.rich_file.instance_write(:file_name, name)
      end
    end
  end
end

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    # use require_dependency if you plan to utilize development mode
    require_dependency 'rich'
    RichFile.send(:include, Rich::RichFilePatch)
  end
else
  Dispatcher.to_prepare do
    require_dependency 'rich'
    RichFile.send(:include, Rich::RichFilePatch)
  end
end