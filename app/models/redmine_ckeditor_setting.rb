class RedmineCkeditorSetting
  def self.setting
    Setting[:plugin_redmine_ckeditor] || {}
  end

  def self.default
    ["1", true].include?(setting[:default])
  end

  def self.toolbar_string
    setting[:toolbar] || RedmineCkeditor::DEFAULT_TOOLBAR
  end

  def self.toolbar
    bars = []
    bar = []
    toolbar_string.split(",").each {|item|
      case item
      when '/'
        bars.push(bar, item)
        bar = []
      when '--'
        bars.push(bar)
        bar = []
      else
        bar.push(item)
      end
    }
    
    bars.push(bar) unless bar.empty?
    bars
  end

  def self.skin
    setting[:skin] || "moono"
  end

  def self.ui_color
    setting[:ui_color] || "#f4f4f4"
  end
end
