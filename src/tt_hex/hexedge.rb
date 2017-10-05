require 'tt_hex/segment'

module TT::Plugins::Hex

  class HexEdge < Segment
    
    # The index is used to keep track of the edge position. This is useful to
    # traverse and determine edge's orientation to each other.
    attr_reader :index

    # @param [Integer] index
    # @param [Geom::Point3d] point1
    # @param [Geom::Point3d] point2
    def initialize(index, point1, point2)
      super(point1, point2)
      @index = index
    end

  end # class

end # module
