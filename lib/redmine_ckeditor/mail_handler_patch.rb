require_dependency 'mail_handler'

module RedmineCkeditor
  module MailHandlerPatch
    extend ActiveSupport::Concern
    include ActionView::Helpers::TextHelper

    included do
      unloadable
      alias_method_chain :cleaned_up_text_body, :ckeditor
      alias_method_chain :extract_keyword!, :ckeditor
    end

    def cleaned_up_text_body_with_ckeditor
      if RedmineCkeditor.enabled?
        simple_format(cleaned_up_text_body_without_ckeditor)
      else
        cleaned_up_text_body_without_ckeditor
      end
    end

    def extract_keyword_with_ckeditor!(text, attr, format=nil)
      text = cleaned_up_text_body_without_ckeditor if RedmineCkeditor.enabled?
      extract_keyword_without_ckeditor!(text, attr, format)
    end
  end

  MailHandler.send(:include, MailHandlerPatch)
end
