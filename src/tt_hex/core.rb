require 'tt_hex/hexui'

module TT::Plugins::Hex

  unless file_loaded?(__FILE__)
    cmd = UI::Command.new('HexUp') {
      self.init_ui
    }
    cmd.tooltip = 'Start HexUp'
    cmd.small_icon = File.join(PATH, 'icons', 'iconmonstr-hexagon-2.svg')
    cmd.large_icon = File.join(PATH, 'icons', 'iconmonstr-hexagon-2.svg')
    cmd_init_ui = cmd

    toolbar = UI.toolbar('HexUp')
    toolbar.add_item(cmd_init_ui)

    menu = UI.menu('Plugins')
    menu.add_item(cmd_init_ui)

    file_loaded(__FILE__)
  end

  def self.init_ui
    tool = HexUI.new
    Sketchup.active_model.select_tool(tool)
  end

  # TT::Plugins::Hex.reload
  def self.reload( tt_lib = false )
    original_verbose = $VERBOSE
    $VERBOSE = nil
    x = Dir.glob(File.join(PATH, '**/*.{rb,rbs}') ).each { |file|
      load file
    }
    x.length
  ensure
    $VERBOSE = original_verbose
  end

end # module
