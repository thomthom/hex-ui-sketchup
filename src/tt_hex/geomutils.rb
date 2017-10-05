module TT::Plugins::Hex

  module GeomUtils

    # @param [Geom::Point3d] center
    # @param [Numeric] radius
    # @param [Numeric] start_angle
    # @param [Numeric] end_angle
    # @param [Geom::Vector3d] xaxis
    # @param [Integer] segments
    #
    # @return [Array<Geom::Point3d>]
    def arc2d(center, radius, start_angle, end_angle, xaxis = X_AXIS, segments = 24)
      full_angle = end_angle - start_angle
      segment_angle = full_angle / segments
      t = Geom::Transformation.axes(center, xaxis, xaxis * Z_AXIS, Z_AXIS)
      arc = []
      (0..segments).each { |i|
        angle = start_angle + (segment_angle * i)
        x = radius * Math.cos(angle)
        y = radius * Math.sin(angle)
        arc << Geom::Point3d.new(x, y, 0).transform!(t)
      }
      arc
    end

    # @param [Geom::Point3d] center
    # @param [Numeric] radius
    # @param [Geom::Vector3d] xaxis
    # @param [Integer] segments
    #
    # @return [Array<Geom::Point3d>]
    def circle2d(center, radius, xaxis = X_AXIS, segments = 24)
      segments = segments.to_i
      angle = 360.degrees - (360.degrees / segments)
      arc2d(center, radius, 0, angle, xaxis, segments - 1)
    end

    # @param [Geom::Point3d] center
    # @param [Numeric] radius
    # @param [Numeric] start_angle
    # @param [Numeric] end_angle
    # @param [Geom::Vector3d] xaxis
    # @param [Integer] segments
    #
    # @return [Array<Geom::Point3d>]
    def pie2d(center, radius, start_angle, end_angle, xaxis = X_AXIS, segments = 24)
      points = arc2d(center, radius, start_angle, end_angle, xaxis, segments)
      points << center
      points
    end

    # @param [Geom::Point3d] position
    # @param [Geom::Vector3d] direction
    #
    # @return [Geom::Transformation]
    def orient2d(position, direction)
      yaxis = direction
      xaxis = yaxis * Z_AXIS
      Geom::Transformation.new(position, xaxis, yaxis)
    end

    # @param [Array(Geom::Point3d, Geom::Point3d)]
    #
    # @return [Geom::Point3d]
    def midpoint(segment)
      Geom.linear_combination(0.5, segment.first, 0.5, segment.last) 
    end

  end # module

end # module
