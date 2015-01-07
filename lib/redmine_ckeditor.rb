module RedmineCkeditor
  extend ActionView::Helpers

  class << self
    def root
      @root ||= Pathname(File.expand_path(File.dirname(File.dirname(__FILE__))))
    end

    def assets_root
      @assets_root ||= "#{Redmine::Utils.relative_url_root}/plugin_assets/redmine_ckeditor"
    end

    def allowed_tags
      @allowed_tags ||= %w[
        a abbr acronym address blockquote b big br caption cite code dd del dfn
        div dt em h1 h2 h3 h4 h5 h6 hr i img ins kbd li ol p pre samp small span
        strike s strong sub sup table tbody td tfoot th thead tr tt u ul var iframe
      ]
    end

    def allowed_attributes
      @allowed_attributes ||= %w[
        href src width height alt cite datetime title class name xml:lang abbr dir
        style align valign border cellpadding cellspacing colspan rowspan nowrap
        start reversed
      ]
    end

    def default_toolbar
      @default_toolbar ||= %w[
        Source ShowBlocks -- Undo Redo - Find Replace --
        Bold Italic Underline Strike - Subscript Superscript -
        NumberedList BulletedList - Outdent Indent Blockquote -
        JustifyLeft JustifyCenter JustifyRight JustifyBlock -
        Link Unlink - richImage Table HorizontalRule
        /
        Styles Format Font FontSize - TextColor BGColor
      ].join(",")
    end

    def config
      ActionController::Base.config
    end

    def plugins
      @plugins ||= Dir.glob(root.join("assets/ckeditor-contrib/plugins/*")).map {
        |path| File.basename(path)
      }
    end

    def skins
      @skins ||= Dir.glob(root.join("assets/ckeditor-contrib/skins/*")).map {
        |path| File.basename(path)
      }
    end

    def skin_options
      options_for_select(["moono"] + skins, :selected => RedmineCkeditorSetting.skin)
    end

    def enter_mode_options
      options_for_select({:p => 1, :br => 2, :div => 3},
        :selected => RedmineCkeditorSetting.enter_mode)
    end

    def toolbar_location_options
      options_for_select(["top", "bottom"],
        :selected => RedmineCkeditorSetting.toolbar_location)
    end

    def ckeditor_config
      @ckeditor_config ||= begin
        conf = {
          :extraPlugins => plugins.join(","),
          :allowedContent => true,
          :bodyClass => "wiki",
          :basicEntities => false,
          :entities => false,
          :removePlugins => 'div,flash,forms,iframe',
          :forcePasteAsPlainText => false
        }
        file = Rails.root.join("config/ckeditor.yml")
        conf.merge!(YAML.load_file(file).symbolize_keys) if file.exist?
        conf
      end
    end

    def options(scope_object = nil)
      scope_type = scope_object && scope_object.class.model_name
      scope_id = scope_object && scope_object.id

      skin = RedmineCkeditorSetting.skin
      skin += ",#{assets_root}/ckeditor-contrib/skins/#{skin}/" if skin != "moono"

      rich_options = Rich.options({
        :contentsCss => [stylesheet_path("application"), "#{assets_root}/stylesheets/editor.css"],
        :scoped => scope_object ? true : false,
        :allow_document_uploads => true,
        :allow_embeds => true,
        :default_style => :original,
        :richBrowserUrl => "#{Redmine::Utils.relative_url_root}/rich/files/"
      }, scope_type, scope_id)
      rich_options.delete(:removeDialogTabs)
      rich_options.delete(:format_tags)
      rich_options.delete(:stylesSet)
      rich_options.merge(ckeditor_config.merge({
        :skin => skin,
        :uiColor => RedmineCkeditorSetting.ui_color,
        :enterMode => RedmineCkeditorSetting.enter_mode,
        :shiftEnterMode => RedmineCkeditorSetting.shift_enter_mode,
        :startupOutlineBlocks => RedmineCkeditorSetting.show_blocks,
        :toolbarCanCollapse => RedmineCkeditorSetting.toolbar_can_collapse,
        :toolbarStartupExpanded => !RedmineCkeditorSetting.toolbar_can_collapse,
        :toolbarLocation => RedmineCkeditorSetting.toolbar_location,
        :toolbar => RedmineCkeditorSetting.toolbar,
        :width => RedmineCkeditorSetting.width,
        :height => RedmineCkeditorSetting.height
      }))
    end

    def enabled?
      Setting.text_formatting == "CKEditor"
    end

    def apply_patch
      require 'redmine_ckeditor/application_helper_patch'
      require 'redmine_ckeditor/queries_helper_patch'
      require 'redmine_ckeditor/rich_files_helper_patch'
      require 'redmine_ckeditor/rich_file_patch'
      require 'redmine_ckeditor/rich_files_controller_patch'
      require 'redmine_ckeditor/journals_controller_patch'
      require 'redmine_ckeditor/messages_controller_patch'
    end
  end
end

require 'redmine_ckeditor/hooks/journal_listener'
require 'redmine_ckeditor/pdf_patch'
