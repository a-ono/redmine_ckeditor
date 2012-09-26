require_dependency 'journals_controller'

module RedmineCkeditor
  module JournalsControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        alias_method_chain :new, :ckeditor
      end
    end

    module InstanceMethods
      def new_with_ckeditor
        unless RedmineCkeditor.enabled?
          new_without_ckeditor
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
        @content = "<p>#{ll(Setting.default_language, :text_user_wrote, user)}</p>"
        @content << "<blockquote>#{ActionView::Base.full_sanitizer.sanitize(text)}</blockquote><p/>"

        render "new_with_ckeditor"
      end
    end
  end
end
