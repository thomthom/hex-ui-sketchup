require 'tt_hex/baseobject'

module TT::Plugins::Hex

  class Hex < BaseObject

    attr_accessor :parent

    COLOR_BACKGROUND_NORMAL = Sketchup::Color.new(255, 0, 0, 128)
    COLOR_BACKGROUND_HOVER = Sketchup::Color.new(0, 255, 0, 128)
    COLOR_BORDER = Sketchup::Color.new(255, 0, 0)

    BORDER_SIZE = 2
    PADDING = 1

    RADIUS = 30

    SNAP_DISTANCE = 10

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
    end

    # @return [Geom::Point3d]
    def position
      # While in a drag the position property isn't set yet, so we much return
      # the dragged position first if available.
      @drag_position || @position
    end

    # @return [Array<Geom::Point3d>]
    def polygon
      hexagon(position, RADIUS)
    end

    # @param [Array<Geom::Point3d>] points Array of 6 points.
    #
    # @return [Array<Array(Geom::Point3d, Geom::Point3d)>]    
    def segments(points)
      6.times.map { |i|
        # TODO: Consider a custom Segment class to wrap data.
        [ points[i - 1], points[i] ]
      }
    end

    # Check if a screen position is within the hex.
    #
    # @param [Geom::Point3d] point
    def point_inside?(point)
      Geom.point_in_polygon_2D(point, hexagon(position, RADIUS), true)
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
      @position = @drag_position if @drag_position
      @left_button_down = nil
      @drag_position = nil
      UI.play_sound(File.join(__dir__, 'audio', 'beep.wav'))
    end

    # @param [Integer] flags
    # @param [Float] x
    # @param [Float] y
    # @param [Sketchup::View] view
    def onMouseMove(flags, x, y, view)
      if @left_button_down
        offset = @left_button_down.vector_to([x, y, 0])
        if offset.valid?
          # If the hex moves, then check if it snaps to anything.
          new_hex_position = @position.offset(offset)
          @drag_position = snap(new_hex_position.x, new_hex_position.y)
        end
      end
    end

    # @param [Sketchup::View] view
    def draw(view)
      # TODO: Cache data structures for drawing and invalidate only when it
      #   moves.
      radius = RADIUS - (BORDER_SIZE / 2) - PADDING
      points = hexagon(position, radius)

      view.drawing_color = background_color
      view.draw2d(GL_POLYGON, points)

      view.line_stipple = ''
      view.line_width = BORDER_SIZE
      view.drawing_color = COLOR_BORDER
      view.draw2d(GL_LINE_LOOP, points)

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

    # @param [Array(Geom::Point3d, Geom::Point3d)]
    #
    # @return [Geom::Point3d]
    def midpoint(segment)
      # TODO: Move to GeomUtils.
      # TODO: Expose as part of Segment.
      Geom.linear_combination(0.5, segment.first, 0.5, segment.last) 
    end

    # @param [Geom::Point3d] point
    # @param [Array(Geom::Point3d, Geom::Point3d)] segment
    #
    # @return [Geom::Vector3d]
    def vector_to_midpoint(point, segment)
      # TODO: Expose as part of Segment.
      point.vector_to(midpoint(segment))
    end

    # Used to take a potential new position of a hex and snap it to its
    # siblings. The returned value should be used for the hex's new position.
    #
    # @param [Float] x
    # @param [Float] y
    #
    # @return [Geom::Point3d]
    def snap(x, y)
      # TODO: This might belong to the parent - acting as a manager for its
      #   childen's positions.
      point = Geom::Point3d.new(x, y, 0)
      points = hexagon(point, RADIUS)
      this_segments = segments(points)
      parent.items.each { |item|
        next if item == self
        this_segments.each_with_index { |this_segment, i|
          this_vector = vector_to_midpoint(point, this_segment)

          item_points = hexagon(item.position, RADIUS)
          item.segments(item_points).each_with_index { |other_segment, j|
            other_vector = vector_to_midpoint(item.position, other_segment)

            next unless this_vector.samedirection?(other_vector.reverse)

            this_midpoint = midpoint(this_segment)
            other_midpoint = midpoint(other_segment)

            vector = this_midpoint.vector_to(other_midpoint)
            next unless vector.valid?
            next if vector.length > SNAP_DISTANCE

            return point.offset(vector)
          }
        }
      }
      point
    end

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

    # @param [Geom::Point3d] center
    # @param [Numeric] radius
    # @param [Integer] n Number of sides
    #
    # @return [Array<Geom::Point3d>]
    def ngon(center, radius, n)
      points = []
      n.times { |i|
        x = center.x + radius * Math.cos(2 * Math::PI * i / n)
        y = center.y + radius * Math.sin(2 * Math::PI * i / n)
        points << Geom::Point3d.new(x, y, 0)
      }
      points
    end

  end # class

end # module
