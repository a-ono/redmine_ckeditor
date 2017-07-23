class RedmineCkeditorSetting
  def self.setting
    Setting[:plugin_redmine_ckeditor] || {}
  end

  def self.default
    ["1", true].include?(setting["default"])
  end

  def self.toolbar_string
    setting["toolbar"] || RedmineCkeditor.default_toolbar
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
    setting["skin"] || "moono-lisa"
  end

  def self.ui_color
    setting["ui_color"] || "#f4f4f4"
  end

  def self.enter_mode
    (setting["enter_mode"] || 1).to_i
  end

  def self.shift_enter_mode
    enter_mode == 2 ? 1 : 2
  end

  def self.show_blocks
    (setting["show_blocks"] || 1).to_i == 1
  end

  def self.toolbar_can_collapse
    setting["toolbar_can_collapse"].to_i == 1
  end

  def self.toolbar_location
    setting["toolbar_location"] || "top"
  end

  def self.width
    setting["width"]
  end

  def self.height
    setting["height"] || 400
  end
end
