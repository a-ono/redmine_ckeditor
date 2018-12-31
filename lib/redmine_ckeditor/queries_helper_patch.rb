require_dependency 'queries_helper'

module RedmineCkeditor
  module QueriesHelperPatch
    def csv_value(column, issue, value)
      if RedmineCkeditor.enabled? && column.name == :description
        text = Rails::Html::FullSanitizer.new.sanitize(value.to_s)
        text.gsub(/(?:\r\n\t*)+/, "\r").gsub("&nbsp;", " ").strip
      else
        super
      end
    end
  end
end

QueriesHelper.prepend RedmineCkeditor::QueriesHelperPatch
