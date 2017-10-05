require 'tt_hex/baseobject'
require 'tt_hex/geomutils'
require 'tt_hex/hexedge'

module TT::Plugins::Hex

  class Hex < BaseObject

    attr_accessor :parent
    attr_reader :position

    include GeomUtils

    COLOR_BACKGROUND_NORMAL = Sketchup::Color.new(255, 0, 0, 128)
    COLOR_BACKGROUND_HOVER = Sketchup::Color.new(0, 255, 0, 128)
    COLOR_BORDER = Sketchup::Color.new(255, 0, 0)

    BORDER_SIZE = 2 # Pixels
    PADDING = 1 # Pixels

    RADIUS = 30 # Pixels

    ICONS = {
      :alert => "\uf071",
      :arrows => "\uf047 ",
      :check => "\uf14a",
      :cog => "\uf013",
      :file => "\uf15b",
      :trash => "\uf1f8",
      :unlock => "\uf13e",
      :user => "\uf007",
    }

    def initialize(position = ORIGIN)
      @parent = nil
      @position = Geom::Point3d.new(position)
      @icon = ICONS.values.sample

      @left_button_down = nil
    end

    # @return [Array<Geom::Point3d>]
    def polygon
      hexagon(position, RADIUS)
    end

    # @return [Array<HexEdge>]    
    def segments
      ngon_segments(polygon)
    end

    # Check if a screen position is within the hex.
    #
    # @param [Geom::Point3d] point
    def point_inside?(point)
      Geom.point_in_polygon_2D(point, hexagon(position, RADIUS), true)
    end

    # @param [HexEdge] edge
    # @return [HexEdge]
    def opposite_edge(edge)
      i = (edge.index + 3) % 6
      segments[i]
    end

    # @param [Integer] flags
    # @param [Float] x
    # @param [Float] y
    # @param [Sketchup::View] view
    def onLButtonDown(flags, x, y, view)
      if point_inside?([x, y, 0])
        @left_button_down = Geom::Point3d.new(x, y, 0)
      end
    end

    # @param [Integer] flags
    # @param [Float] x
    # @param [Float] y
    # @param [Sketchup::View] view
    def onLButtonDoubleClick(flags, x, y, view)
      onLButtonDown(flags, x, y, view)
    end

    # @param [Integer] flags
    # @param [Float] x
    # @param [Float] y
    # @param [Sketchup::View] view
    def onLButtonUp(flags, x, y, view)
      @left_button_down = nil
      if point_inside?([x, y, 0])
        # TODO: Make this method return true/false to indicate it was clicked.
        #   Make the container emit the sound - only once.
        UI.play_sound(File.join(__dir__, 'audio', 'beep.wav'))
      end
    end

    # @param [Integer] flags
    # @param [Float] x
    # @param [Float] y
    # @param [Sketchup::View] view
    def onMouseMove(flags, x, y, view)
      if @left_button_down
        offset = @position.vector_to([x, y, 0])
        if offset.valid?
          # If the hex moves, then check if it snaps to anything.
          new_hex_position = @position.offset(offset)
          @position = parent.snap(new_hex_position.x, new_hex_position.y)
        end
      end
    end

    # @param [Sketchup::View] view
    def draw(view)
      # TODO: Cache data structures for drawing and invalidate only when it
      #   moves.
      radius = RADIUS - (BORDER_SIZE / 2) - PADDING
      points = hexagon(position, radius)

      # Background
      view.drawing_color = background_color
      view.draw2d(GL_POLYGON, points)

      # Border
      view.line_stipple = ''
      view.line_width = BORDER_SIZE
      view.drawing_color = COLOR_BORDER
      view.draw2d(GL_LINE_LOOP, points)

      # Glyph
      # TODO: Cache this option hash elsewhere.
      options = {
        :font => "FontAwesome", # TODO: Check if available on system.
        :size => 20,
        :align => TextAlignCenter,
        :color => COLOR_BORDER
      }
      point = position.offset([0, -13, 0])
      view.draw_text(point, @icon, options)
    end

    private

    # @return [Sketchup::Color]
    def background_color
      @left_button_down ? COLOR_BACKGROUND_HOVER : COLOR_BACKGROUND_NORMAL
    end

    # @param [Geom::Point3d] center
    # @param [Numeric] radius
    #
    # @return [Array<Geom::Point3d>]
    def hexagon(center, radius)
      ngon(center, radius, 6)
    end

    # @param [Array<Geom::Point3d>] points
    #
    # @return [Array<HexEdge>]
    def ngon_segments(points)
      points.size.times.map { |i|
        HexEdge.new(i, points[i - 1], points[i])
      }
    end

  end # class

end # module
