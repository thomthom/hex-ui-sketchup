require 'tt_hex/debugview'
require 'tt_hex/hex'
require 'tt_hex/hexview'

module TT::Plugins::Hex

  class HexUI

    attr_accessor :layers

    def initialize
      @layers = {
        hex: HexView.new(self),
        debug: DebugView.new(self),
      }
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
      @layers.each { |key, layer| layer.onLButtonDown(flags, x, y, view) }
      view.invalidate
    end

    def onLButtonUp(flags, x, y, view)
      @layers.each { |key, layer| layer.onLButtonUp(flags, x, y, view) }
      view.invalidate
    end

    # TODO: onLButtonUp doesn't seem to trigger after this event.
    #   See if faking an up-click with a timer (yuck) can work?
    # def onLButtonDoubleClick(flags, x, y, view)
    #   @items.each { |item| item.onLButtonDoubleClick(flags, x, y, view) }
    #   view.invalidate
    # end

    def onMouseMove(flags, x, y, view)
      @layers.each { |key, layer| layer.onMouseMove(flags, x, y, view) }
      view.invalidate
    end

    def getMenu(menu, flags, x, y, view)
      menu.add_item('Add Hex') {
        layers[:hex].add_hex(x, y)
      }
      menu.add_separator
      id = menu.add_item('Debug View') {
        layers[:debug].enabled = !layers[:debug].enabled?
      }
      menu.set_validation_proc(id)  {
        layers[:debug].enabled? ? MF_CHECKED : MF_ENABLED
      }
    end

    def draw(view)
      @layers.each { |key, layer| layer.draw(view) }
    end

  end # class

end # module
