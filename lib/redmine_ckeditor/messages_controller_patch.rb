require_dependency 'messages_controller'

module RedmineCkeditor
  module MessagesControllerPatch
    def quote
      unless RedmineCkeditor.enabled?
        return super
      end

      @subject = @message.subject
      @subject = "RE: #{@subject}" unless @subject.starts_with?('RE:')
      @content = "<p>#{ll(I18n.locale, :text_user_wrote, @message.author)}</p>"
      @content << "<blockquote>#{ActionView::Base.full_sanitizer.sanitize(@message.content.to_s)}</blockquote><p/>"

      render "quote_with_ckeditor"
    end
  end
end

MessagesController.prepend RedmineCkeditor::MessagesControllerPatch
