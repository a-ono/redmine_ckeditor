module RedmineCkeditor::Hooks
  class JournalListener < Redmine::Hook::ViewListener
    def view_journals_notes_form_after_notes(context)
      return unless RedmineCkeditor.enabled?

      journal = context[:journal]
      javascript_tag <<-EOT
        (function() {
          var note_id = "journal_#{journal.id}_notes";
          CKEDITOR.replace(note_id);
          var note = $(note_id);

          var save_button = note.parentNode.getElementsBySelector('input[type="submit"]').first();
          var preview_button = save_button.next();
          var cancel_button = preview_button.next();

          save_button.onclick = function() {
            var editor = CKEDITOR.instances[note_id];
            note.value = editor.getData();
            editor.destroy();
          };

          preview_button.hide();
          var cancel = cancel_button.onclick;
          cancel_button.onclick = function() {
            CKEDITOR.instances[note_id].destroy();
            cancel();
            return false;
          }
        })();
      EOT
    end
  end
end

