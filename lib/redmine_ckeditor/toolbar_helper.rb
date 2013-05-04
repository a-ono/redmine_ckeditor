module RedmineCkeditor
  module ToolbarHelper
    include ActionView::Helpers
    include Redmine::I18n

    @@dict = {}
    
    def self.included(base)
      base.extend RedmineCkeditor::ToolbarHelper
    end

    #
    # Return Base ActionController instance of config
    #
    def config
      ActionController::Base.config
    end
    
    #
    # Renamed because config was being queries for cache control / asset control etc, which is undesired
    #
    def configuration(*args)
      result = @@toolbar_config ||=
        YAML.load_file(RedmineCkeditor.root.join('config/toolbar.yml'))

      args.each {|arg|
        break unless result = result[arg]
      }
      result
    end

    def button_names
      @@toolbar_buttons ||= configuration.to_a.sort{|a, b|
        a[1]["position"] <=> b[1]["position"]
      }.map{|item| item[0]}
    end

    def button_label(item, locale=I18n.locale)
      locale = locale.to_s.downcase
      unless @@dict[locale]
        path = RedmineCkeditor.root.join("assets/ckeditor/lang/#{locale}.js")

        h = @@dict[locale] = {}
        path.file? && File.open(path, "r:BOM|UTF-8") {|f|
          context = ExecJS.compile(<<-EOT)
            function lang() {
              var CKEDITOR = {lang: {}};
              #{f.read}
              return CKEDITOR.lang["#{locale}"];
            }
          EOT
          dict = context.call("lang")

          configuration.each {|name, conf|
            label_keys = conf["label"] || name.camelize(:lower)
            h[name] = label_keys.to_a.inject(dict) {|d, key|
              d ? d[key] : nil
            }
          }
        }
      end

      @@dict[locale][item] || (locale != "en" ? button_label(item, "en") : item)
    end

    def selected_items
      RedmineCkeditorSetting.toolbar_string.split(",")
    end

    def left_options
      items = selected_items
      options_for_select(button_names.reject {|button|
        items.include?(button)
      }.map {|item|
        [button_label(item), item]
      })
    end

    def right_options
      options_for_select(selected_items.map {|item|
        [button_label(item), item]
      })
    end
  end
end
