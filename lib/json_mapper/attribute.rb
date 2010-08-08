class Attribute

  attr_accessor :name, :source_attributes, :type, :options

  def initialize(name, source_attributes, type, options = {})
    
    self.name = name
    self.source_attributes = source_attributes.is_a?(Array) ? source_attributes : [ source_attributes ]
    self.type = type
    self.options = options

  end

  def method_name
    @method_name ||= self.name.to_s.tr("-", "_")
  end

  def self_referential?
    self.source_attributes.include?("self")
  end

  def typecast(value)

    return value if value.nil?

    if self.type == String then return value.to_s
    elsif self.type == DelimitedString
      self.options[:delimiter] ||= ","
      return value.split(self.options[:delimiter])
    elsif self.type == Integer
      begin
        return value.to_i
      rescue
        return nil
      end
    elsif self.type == Boolean then return %w(true t 1).include?(value.to_s.downcase)
    elsif self.type == DateTime then return Date.parse(value.to_s)
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
