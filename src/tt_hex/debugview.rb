require 'tt_hex/baseobject'
require 'tt_hex/geomutils'
require 'tt_hex/glutils'

module TT::Plugins::Hex

  class DebugView < BaseObject

    include GeomUtils
    include GLUtils

    attr_accessor :parent

    def initialize(parent)
      @parent = parent
      @enabled = Sketchup.read_default('tt_hex', 'debugview', false)
    end

    # @param [Boolean] value
    def enabled=(value)
      @enabled = value
      Sketchup.write_default('tt_hex', 'debugview', @enabled)
    end

    # @return [Boolean]
    def enabled?
      @enabled
    end

    # @param [Integer] flags
    # @param [Float] x
    # @param [Float] y
    # @param [Sketchup::View] view
    def onLButtonDown(flags, x, y, view)
    end

    # @param [Integer] flags
    # @param [Float] x
    # @param [Float] y
    # @param [Sketchup::View] view
    def onLButtonDoubleClick(flags, x, y, view)
    end

    # @param [Integer] flags
    # @param [Float] x
    # @param [Float] y
    # @param [Sketchup::View] view
    def onLButtonUp(flags, x, y, view)
    end

    # @param [Integer] flags
    # @param [Float] x
    # @param [Float] y
    # @param [Sketchup::View] view
    def onMouseMove(flags, x, y, view)
    end

    # @param [Sketchup::View] view
    def draw(view)
      return unless enabled?
      positions = []
      midpoints = []

      parent.layers[:hex].items.each { |item|
        positions << circle2d(item.position, 4, X_AXIS, 12)
        item.segments.each { |segment|
          midpoints << circle2d(segment.midpoint, 2, X_AXIS, 6)
        }
      }

      view.line_stipple = ''
      view.drawing_color = 'yellow'
      positions.each { |polygon|
        view.draw2d(GL_POLYGON, polygon)
      }
      midpoints.each { |polygon|
        view.draw2d(GL_POLYGON, polygon)
      }
    end

  end # class

end # module
