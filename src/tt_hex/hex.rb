require 'tt_hex/baseobject'
require 'tt_hex/geomutils'
require 'tt_hex/segment'

module TT::Plugins::Hex

  class Hex < BaseObject

    attr_accessor :parent

    include GeomUtils

    COLOR_BACKGROUND_NORMAL = Sketchup::Color.new(255, 0, 0, 128)
    COLOR_BACKGROUND_HOVER = Sketchup::Color.new(0, 255, 0, 128)
    COLOR_BORDER = Sketchup::Color.new(255, 0, 0)

    BORDER_SIZE = 2 # Pixels
    PADDING = 1 # Pixels

    RADIUS = 30 # Pixels

    SNAP_DISTANCE = 10 # Pixels

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

      @drag_position = nil
      @left_button_down = nil
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

    # @return [Array<Segment>]    
    def segments
      ngon_segments(polygon)
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
      this_segments = ngon_segments(points) # Cache.
      parent.items.each { |item|
        # Traverse through all the siblings and see if this hex is close enough
        # to snap to either of them.
        next if item == self
        # Each side of the hex is compared to the sides of the other hex'.
        this_segments.each_with_index { |this_segment, i|
          # Get the vector from the hex's position (center) to the mid-point
          # of its current side we are checking. This is used later to check
          # is we are close enough to snap.
          # TODO: Potential to optimize at time of reposition if this
          #   computation takes too much time.
          this_vector = point.vector_to(this_segment.midpoint)
          item.segments.each_with_index { |other_segment, j|
            # Get the vector from the other hex's position to its side which
            # is being compared. If the normals are opposing then they can
            # be considered for snapping.
            other_vector = item.position.vector_to(other_segment.midpoint)
            next unless this_vector.samedirection?(other_vector.reverse)
            # Hexes will snap when two of their side's mid-point is within a
            # given distance.
            vector = this_segment.midpoint.vector_to(other_segment.midpoint)
            next unless vector.valid?
            next if vector.length > SNAP_DISTANCE
            # When there's a snap the computed new position is returned for the
            # caller to use.
            # TODO: Check if another hex is at this position already.
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

  end # class

end # module
