class RedmineCkeditorSetting
  def self.setting
    Setting[:plugin_redmine_ckeditor] || {}
  end

  def self.default
    ["1", true].include?(setting[:default])
  end

  def self.toolbar
    buttons = setting[:toolbar] || RedmineCkeditor::DEFAULT_TOOLBAR

    if buttons.is_a?(String)
      bars = []
      bar =[]
      buttons.split(",").each {|item|
        if item == "/"
          bars.push(bar, item)
          bar = []
        else
          bar.push(item)
        end
      }
      
      buttons = bar.size > 0 ? bars.push(bar) : bars
    end

    buttons
  end
end
