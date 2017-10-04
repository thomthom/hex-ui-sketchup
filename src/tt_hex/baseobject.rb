module TT::Plugins::Hex

  class BaseObject

    # @return [String]
    def typename
      self.class.name.split('::').last
    end

    # @return [String]
    def inspect
      "<#{self.class}:#{object_id_hex} #{object_info}>"
    end

    # @return [String]
    def to_s
      "#{typename} #{object_info}"
    end

    private

    # @return [String]
    def object_id_hex
      "0x%x" % (object_id << 1)
    end

    # @return [String]
    def object_info
      ''
    end

  end # class

end # module
