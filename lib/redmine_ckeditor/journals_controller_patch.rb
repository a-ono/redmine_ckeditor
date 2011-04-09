require_dependency 'issues_controller'

module RedmineCkeditor
  module IssuesControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        #alias_method_chain :reply, :ckeditor
      end
    end

    module InstanceMethods
      def reply_with_ckeditor
        unless Setting.text_formatting == "CKEditor"
          reply_without_ckeditor
          return
        end

        journal = Journal.find(params[:journal_id]) if params[:journal_id]
        if journal
          user = journal.user
          text = journal.notes
        else
          user = @issue.author
          text = @issue.description
        end
        content = "<p>#{ll(Setting.default_language, :text_user_wrote, user)}</p>"
        content << "<blockquote>#{ActionView::Base.full_sanitizer.sanitize(text)}</blockquote><p/>"

        render(:update) {|page|
          page.<< "CKEDITOR.instances['notes'].setData(#{content.inspect});"
          page << "showAndScrollTo('update', 'notes');"
        }
      end
    end
  end
end
