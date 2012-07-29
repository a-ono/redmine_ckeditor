require 'redmine_ckeditor/journals_controller_patch'
require 'redmine_ckeditor/toolbar_helper'
require 'redmine_ckeditor/hooks/journal_listener'

module RedmineCkeditor
  include ToolbarHelper
  PLUGIN_DIR = File.expand_path(File.dirname(File.dirname(__FILE__)))

  ALLOWED_TAGS = %w[
    a abbr acronym address blockquote b big br caption cite code dd del dfn
    div dt em h1 h2 h3 h4 h5 h6 hr i img ins kbd li ol p pre samp small span
    strike strong sub sup table tbody td tfoot th thead tr tt u ul var
  ]

  ALLOWED_ATTRIBUTES = %w[
    href src width height alt cite datetime title class name xml:lang abbr dir
    style align valign border cellpadding cellspacing colspan rowspan nowrap
  ]

  DEFAULT_TOOLBAR = [
    %w[Source - Preview - Maximize ShowBlocks - Templates - PasteText PasteFromWord -
      Undo Redo - Find Replace
    ], '/',
    %w[Bold Italic Underline Strike - Subscript Superscript -
      NumberedList BulletedList - Outdent Indent Blockquote -
      JustifyLeft JustifyCenter JustifyRight JustifyBlock -
      Link Unlink Anchor - Image Table HorizontalRule SpecialChar
    ], '/',
    %w[Styles Format Font FontSize - TextColor BGColor]
  ]

  def self.enabled?
    Setting.text_formatting == "CKEditor"
  end

  def self.apply_patch
    JournalsController.send(:include, JournalsControllerPatch)
  end
end
