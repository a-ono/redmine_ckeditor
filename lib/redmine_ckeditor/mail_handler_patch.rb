module RedmineCkeditor
  module MailHandlerPatch
    include ActionView::Helpers::TextHelper

    def cleaned_up_text_body(format = true)
      if RedmineCkeditor.enabled? and format
        simple_format(super())
      else
        super()
      end
    end

    def extract_keyword!(text, attr, format=nil)
      text = cleaned_up_text_body(false) if RedmineCkeditor.enabled?
      super(text, attr, format)
    end
  end
end
