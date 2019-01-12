module RedmineCkeditor
  module ApplicationHelperPatch
    include RedmineCkeditor::Helper

    def format_activity_description(text)
      if RedmineCkeditor.enabled?
        simple_format(truncate(HTMLEntities.new.decode(strip_tags(text.to_s)), :length => 120))
      else
        super
      end
    end
  end
end
