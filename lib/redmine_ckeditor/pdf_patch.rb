require_dependency 'redmine/export/pdf'

module RedmineCkeditor
  module PDFPatch
    def self.included(base)
      base.class_eval do
        alias_method_chain :formatted_text, :ckeditor
        alias_method_chain :get_image_filename, :ckeditor
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

    def get_image_filename_with_ckeditor(attrname)
      img = nil

      if attrname.sub!(/^data:([^\/]+)\/([^;]+);base64,/, '')
        type = $2
        data = attrname.dup

        # for base64 encording image such as 'clipboard_image_paste' plugin
        if @tmp_images.nil?
          @tmp_images = []
        end

        tmp = Tempfile.new([@tmp_images.length.to_s, '.'+type])
        img = tmp.path
        tmp.close

        @tmp_images << img
        File.open(img, 'wb') do |f|
          f.write(Base64.decode64(data))
        end
      else
        # for CKEditor file uploader with 'rich' plugin
        img = if attrname.include?("/rich/rich_files/rich_files/")
          Rails.root.join("public#{URI.decode(attrname)}").to_s
        else
          get_image_filename_without_ckeditor(attrname)
        end
      end
      img
    end
  end

  Redmine::Export::PDF::ITCPDF.send(:include, PDFPatch)
end
