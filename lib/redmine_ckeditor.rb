require 'redmine_ckeditor/journals_controller_patch'
require 'redmine_ckeditor/hooks/journal_listener'

module RedmineCkeditor
  extend ActionView::Helpers

  def self.root
    @root ||= Pathname(File.expand_path(File.dirname(File.dirname(__FILE__))))
  end

  ALLOWED_TAGS = %w[
    a abbr acronym address blockquote b big br caption cite code dd del dfn
    div dt em h1 h2 h3 h4 h5 h6 hr i img ins kbd li ol p pre samp small span
    strike strong sub sup table tbody td tfoot th thead tr tt u ul var
  ]

  ALLOWED_ATTRIBUTES = %w[
    href src width height alt cite datetime title class name xml:lang abbr dir
    style align valign border cellpadding cellspacing colspan rowspan nowrap
  ]

  DEFAULT_TOOLBAR = %w[
    Source ShowBlocks -- Undo Redo - Find Replace --
    Bold Italic Underline Strike - Subscript Superscript -
    NumberedList BulletedList - Outdent Indent Blockquote -
    JustifyLeft JustifyCenter JustifyRight JustifyBlock -
    Link Unlink - richImage Table HorizontalRule
    /
    Format Font FontSize - TextColor BGColor
  ].join(",")

  def self.config
    ActionController::Base.config
  end

  def self.options(overrides = {})
    o = Rich.options({
      :contentsCss => stylesheet_path("application"),
      :bodyClass => "wiki",
      :extraPlugins => 'richfile',
      :removePlugins => 'image',
      :toolbar => RedmineCkeditorSetting.toolbar
    })
    o.delete(:removeDialogTabs)
    o.delete(:format_tags)
    o.merge(overrides)
  end

  def self.enabled?
    Setting.text_formatting == "CKEditor"
  end

  def self.apply_patch
    JournalsController.send(:include, JournalsControllerPatch)
  end
end
