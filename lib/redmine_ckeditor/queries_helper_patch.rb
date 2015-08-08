require_dependency 'queries_helper'

module QueriesHelper
  def csv_value_with_ckeditor(column, issue, value)
    if RedmineCkeditor.enabled? && column.name == :description
      text = Rails::Html::FullSanitizer.new.sanitize(value.to_s)
      text.gsub(/(?:\r\n\t*)+/, "\r").gsub("&nbsp;", " ").strip
    else
      csv_value_without_ckeditor(column, issue, value)
    end
  end
  alias_method_chain :csv_value, :ckeditor
end
