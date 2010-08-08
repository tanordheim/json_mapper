class Attribute

  attr_accessor :name, :source_attributes, :type

  Types = [ String, Integer, Boolean ]

  def initialize(name, source_attributes, type)
    
    self.name = name
    self.source_attributes = source_attributes.is_a?(Array) ? source_attributes : [ source_attributes ]
    self.type = type

  end

  def method_name
    @method_name ||= self.name.to_s.tr("-", "_")
  end

  def typecast(value)

    return value if value.nil?

    if self.type == String then return value.to_s
    elsif self.type == Integer then return value.to_i
    elsif self.type == Boolean then return value.to_s == "true"
    else

      # If our type is a JSONMapper instance, delegate the
      # mapping to that class
      if self.type.new.is_a?(JSONMapper)
        return self.type.parse_json(value)
      else
        return value
      end

    end

  end

end
