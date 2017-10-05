require 'tt_hex/baseobject'
require 'tt_hex/geomutils'
require 'tt_hex/glutils'

module TT::Plugins::Hex

  class HexView < BaseObject

    include GeomUtils
    include GLUtils

    SNAP_DISTANCE = 10 # Pixels

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

    # Used to take a potential new position of a hex and snap it to its
    # siblings. The returned value should be used for the hex's new position.
    #
    # @param [Float] x
    # @param [Float] y
    #
    # @return [Geom::Point3d]
    def snap(x, y)
      point = Geom::Point3d.new(x, y, 0)
      source_segments = Hex.new(point).segments # Cache.
      items.each { |sibling|
        next if sibling == self
        # Traverse through all the siblings and see if this hex is close enough
        # to snap to either of them.
        source_segments.each { |source_segment|
          sibling_segment = sibling.opposite_edge(source_segment)
          # Hexes will snap when two of their side's mid-point is within a
          # given distance.
          vector = source_segment.midpoint.vector_to(sibling_segment.midpoint)
          next unless vector.valid?
          next if vector.length > SNAP_DISTANCE
          # When there's a snap the computed new position is returned for the
          # caller to use.
          # TODO: Check if another hex is at this position already.
          return point.offset(vector)
        }
      }
      point
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
