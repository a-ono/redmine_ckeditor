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
        YAML.load_file(RedmineCkeditor::PLUGIN_DIR + '/config/toolbar.yml')

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
      unless @@dict[locale]
        filename = RedmineCkeditor::PLUGIN_DIR +
          "/assets/javascripts/ckeditor/lang/#{locale}.js"

        h = @@dict[locale] = {}
        if File.file?(filename)
          dict = ActiveSupport::JSON.decode(
            (data = File.read(filename))[data.index("=")+1..data.rindex(";")-1]
          )

          configuration.each {|name, conf|
            label_keys = conf["label"] || name.camelize(:lower)
            h[name] = label_keys.to_a.inject(dict) {|d, key|
              d ? d[key] : nil
            }
          }
        end
      end

      @@dict[locale][item] || (locale != "en" ? button_label(item, "en") : item)
    end

    def toolbar_selector
      items = RedmineCkeditorSetting.toolbar.flatten

      left = button_names.reject {|button|
        items.include?(button)
      }.map {|item|
        [button_label(item), item]
      }

      right = items.map {|item|
        [button_label(item), item]
      }

      button_container = content_tag(:div, <<-EOT, :class => "container")
        <input type="button" class="button" value="#{I18n.t(:add)} >>"
          onclick="moveItem('left', 'right')"/><br/>
        <input type="button" class="button" value="<< #{I18n.t(:remove)}"
          onclick="moveItem('right', 'left')"/><br/><br/>
        <input type="button" class="button" value="#{I18n.t(:separator)} >>"
          onclick="addItem('-')"/><br/>
        <input type="button" class="button" value="#{I18n.t(:line_break)} >>"
          onclick="addItem('/')"/>
      EOT

      html = hidden_field_tag("settings[toolbar]", items.join(",")) +
        content_tag(:select, options_for_select(left),
          :id => "left", :multiple => true, :size => 10,
          :style => "width:250px") +
        button_container +
        content_tag(:select, options_for_select(right),
          :id => "right", :multiple => true, :size => 10,
          :style => "width:250px") +
        content_tag(:div, nil, :class => "clear") +
        content_tag(:div, nil, :id => "toolbar")

      javascript_include_tag(Redmine::Utils.relative_url_root +
        '/plugin_assets/redmine_ckeditor/javascripts/ckeditor/ckeditor') +
      stylesheet_link_tag(Redmine::Utils.relative_url_root +
        '/plugin_assets/redmine_ckeditor/stylesheets/selector') +
      content_tag(:div, html, :class => "selector-container") +
      javascript_tag(<<-EOT)
        function moveItem(from, to) {
          from = $(from);
          to = $(to);
          var index = to.selectedIndex;
          var i = 0;
          while (i < from.options.length) {
            var option = from.options[i];
            if (!option.selected) {
              i++;
              continue;
            }

            option = from.removeChild(option);
            if (option.value != '-' && option.value != '/') {
              if (index < 0) {
                to.appendChild(option)
              } else {
                to.insertBefore(option, to.options[index])
              }
            }
          }
          to.selectedIndex = -1;
          changeHandler();
        }

        function addItem(item) {
          var option = new Option(item, item);
          option.innerHTML = item;
          var to = $('right');
          var index = to.selectedIndex;
          if (index < 0) {
            to.appendChild(option);
          } else {
            to.insertBefore(option, to.options[index])
          }
          changeHandler();
        }
        
        function changeHandler() {
          var values = $A($('right').children).pluck('value');
          $('settings_toolbar').value = values.join(',');
          
          var bars = [];
          var bar = [];
          values.each(function(value) {
            if (value == "/") {
              bars.push(bar, value);
              bar = [];
            } else {
              bar.push(value);
            }
          });
          if (bar.length > 0) bars.push(bar);
          
          CKEDITOR.config.toolbar = bars;
          CKEDITOR.config.language = "#{current_language.to_s.downcase}";
          CKEDITOR.instances['toolbar'].destroy();
          CKEDITOR.replace('toolbar');
        }
        
        CKEDITOR.config.toolbar = #{RedmineCkeditorSetting.toolbar.inspect};
        CKEDITOR.config.language = "#{current_language.to_s.downcase}";
        CKEDITOR.replace('toolbar');
      EOT
    end
  end
end
