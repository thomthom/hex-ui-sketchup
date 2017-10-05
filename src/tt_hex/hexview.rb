require 'tt_hex/baseobject'
require 'tt_hex/geomutils'
require 'tt_hex/glutils'

module TT::Plugins::Hex

  class HexView < BaseObject

    include GeomUtils
    include GLUtils

    attr_accessor :parent
    attr_accessor :items

    def initialize(parent)
      @parent = parent
      @items = []
      add_hex(600, 300)
      add_hex(680, 300)
    end

    # @param [Float] x
    # @param [Float] y
    #
    # @return [Hex]
    def add_hex(x, y)
      hex = Hex.new([x, y, 0])
      hex.parent = self
      @items << hex
    end

    # @param [Integer] flags
    # @param [Float] x
    # @param [Float] y
    # @param [Sketchup::View] view
    def onLButtonDown(flags, x, y, view)
      @items.each { |item| item.onLButtonDown(flags, x, y, view) }
    end

    # @param [Integer] flags
    # @param [Float] x
    # @param [Float] y
    # @param [Sketchup::View] view
    def onLButtonDoubleClick(flags, x, y, view)
      @items.each { |item| item.onLButtonUp(flags, x, y, view) }
    end

    # @param [Integer] flags
    # @param [Float] x
    # @param [Float] y
    # @param [Sketchup::View] view
    def onLButtonUp(flags, x, y, view)
      @items.each { |item| item.onLButtonUp(flags, x, y, view) }
    end

    # @param [Integer] flags
    # @param [Float] x
    # @param [Float] y
    # @param [Sketchup::View] view
    def onMouseMove(flags, x, y, view)
      @items.each { |item| item.onMouseMove(flags, x, y, view) }
    end

    # @param [Sketchup::View] view
    def draw(view)
      @items.each { |item| item.draw(view) }
    end

  end # class

end # module
