require_dependency 'redmine/export/pdf'

module RedmineCkeditor
  module PDFPatch
    def self.included(base)
      base.class_eval do
        alias_method_chain :formatted_text, :ckeditor
        alias_method_chain :getImageFilename, :ckeditor
        alias_method_chain :RDMwriteHTMLCell, :ckeditor
      end
    end

    def formatted_text_with_ckeditor(text)
      html = formatted_text_without_ckeditor(text)
      html = HTMLEntities.new.decode(html) if RedmineCkeditor.enabled?
      html
    end
    
    def RDMwriteHTMLCell_with_ckeditor(w, h, x, y, txt='', attachments=[], border=0, ln=1, fill=0)
      @tmp_images = []
      RDMwriteHTMLCell_without_ckeditor(w, h, x, y, txt, attachments, border, ln, fill)
      @tmp_images.each do |item|
        #logger.info item
        File.delete(item) if File.file?(item)
      end
    end

    def getImageFilename_with_ckeditor(attrname)
      type = attrname[/^data:.+\/(.+);base64,(.*)$/,1]
      data = attrname[/^data:.+\/(.+);base64,(.*)$/,2]
      img = nil
      if data && type
        tmp = Tempfile.new([@tmp_images.length.to_s, '.'+type])
        img = tmp.path
        tmp.close
        @tmp_images << img
        f = File.open(img,'wb')
        f.puts(Base64.decode64(data))
        f.close
      else
        img = getImageFilename_without_ckeditor(attrname)
      end
      img
    end
  end

  Redmine::Export::PDF::ITCPDF.send(:include, PDFPatch)
end
