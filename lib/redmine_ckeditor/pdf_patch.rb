module RedmineCkeditor
  module PDFPatch
    def formatted_text(text)
      html = super
      html = HTMLEntities.new.decode(html) if RedmineCkeditor.enabled?
      html
    end
    
    def RDMwriteHTMLCell(w, h, x, y, txt='', attachments=[], border=0, ln=1, fill=0)
      @tmp_images = []
      super
      @tmp_images.each do |item|
        #logger.info item
        File.delete(item) if File.file?(item)
      end
    end

    def get_image_filename(attrname)
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
          super(attrname)
        end
      end
      img
    end
  end
end

Redmine::Export::PDF::ITCPDF.prepend RedmineCkeditor::PDFPatch
