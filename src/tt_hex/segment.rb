require 'tt_hex/geomutils'

module TT::Plugins::Hex

  class Segment

    include GeomUtils

    # @param [Geom::Point3d] point1
    # @param [Geom::Point3d] point2
    def initialize(point1, point2)
      @points = [point1, point2]
    end

    # @return [Geom::Point3d]
    def midpoint
      super(@points)
    end

  end # class

end # module
