require_dependency 'redmine/export/pdf'

module RedmineCkeditor
  module PDFPatch
    def self.included(base)
      base.class_eval do
        alias_method_chain :formatted_text, :ckeditor
      end
    end

    def formatted_text_with_ckeditor(text)
      html = formatted_text_without_ckeditor(text)
      html = HTMLEntities.new.decode(html) if RedmineCkeditor.enabled?
      html
    end
  end

  Redmine::Export::PDF::ITCPDF.send(:include, PDFPatch)
end
