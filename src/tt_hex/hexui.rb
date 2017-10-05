require 'tt_hex/hex'
require 'tt_hex/debugview'

module TT::Plugins::Hex

  class HexUI

    attr_accessor :items

    def initialize
      # TODO: Add a Container class and delegate to that instead.
      #   This is a Tool class and should act as a controller.
      @items = []
      add_hex(600, 300)
      add_hex(680, 300)
      @debugview = DebugView.new(self)
      @debug = Sketchup.read_default('tt_hex', 'debugview', false)
    end

    def add_hex(x, y)
      hex = Hex.new([x, y, 0])
      hex.parent = self
      @items << hex
    end

    def activate
      Sketchup.active_model.active_view.invalidate
    end

    def deactivate(view)
      view.invalidate
    end

    def resume(view)
      view.invalidate
    end

    def onLButtonDown(flags, x, y, view)
      @items.each { |item| item.onLButtonDown(flags, x, y, view) }
      view.invalidate
    end

    def onLButtonUp(flags, x, y, view)
      @items.each { |item| item.onLButtonUp(flags, x, y, view) }
      view.invalidate
    end

    # TODO: onLButtonUp doesn't seem to trigger after this event.
    #   See if faking an up-click with a timer (yuck) can work?
    # def onLButtonDoubleClick(flags, x, y, view)
    #   @items.each { |item| item.onLButtonDoubleClick(flags, x, y, view) }
    #   view.invalidate
    # end

    def onMouseMove(flags, x, y, view)
      @items.each { |item| item.onMouseMove(flags, x, y, view) }
      view.invalidate
    end

    def getMenu(menu, flags, x, y, view)
      menu.add_item('Add Hex') {
        add_hex(x, y)
      }
      menu.add_separator
      id = menu.add_item('Debug View') {
        @debug = !@debug
        Sketchup.write_default('tt_hex', 'debugview', @debug)
      }
      menu.set_validation_proc(id)  {
        @debug ? MF_CHECKED : MF_ENABLED
      }
    end

    def draw(view)
      @items.each { |item| item.draw(view) }
      @debugview.draw(view) if @debug
    end

  end # class

end # module
