class AttributeList < ::Array

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

  def typecast
  end
  
end
