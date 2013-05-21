require_dependency 'messages_controller'

module RedmineCkeditor
  module MessagesControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        alias_method_chain :quote, :ckeditor
      end
    end

    module InstanceMethods
      def quote_with_ckeditor
        unless RedmineCkeditor.enabled?
          quote_without_ckeditor
          return
        end

        @subject = @message.subject
        @subject = "RE: #{@subject}" unless @subject.starts_with?('RE:')
        @content = "<p>#{ll(I18n.locale, :text_user_wrote, @message.author)}</p>"
        @content << "<blockquote>#{ActionView::Base.full_sanitizer.sanitize(@message.content.to_s)}</blockquote><p/>"

        render "quote_with_ckeditor"
      end
    end
  end

  MessagesController.send(:include, MessagesControllerPatch)
end
