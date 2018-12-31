require_dependency 'journals_controller'

module RedmineCkeditor
  module JournalsControllerPatch
    def new
      unless RedmineCkeditor.enabled?
        return super
      end

      @journal = Journal.visible.find(params[:journal_id]) if params[:journal_id]
      if @journal
        user = @journal.user
        text = @journal.notes
      else
        user = @issue.author
        text = @issue.description
      end
      @content = "<p>#{ll(I18n.locale, :text_user_wrote, user)}</p>"
      @content << "<blockquote>#{text}</blockquote><p/>"

      render "new_with_ckeditor"
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
end

JournalsController.prepend RedmineCkeditor::JournalsControllerPatch
