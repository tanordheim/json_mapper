require "json"

class Boolean; end

module JSONMapper

  def self.included(base)
    base.instance_variable_set("@attributes", {})
    base.extend ClassMethods
  end

  module ClassMethods

    def json_attribute(name, *args)

      source_attributes, type = extract_attribute_data(name, *args)
      attribute = Attribute.new(name, source_attributes, type)
      @attributes[to_s] ||= []
      @attributes[to_s] << attribute

      attr_accessor attribute.method_name.to_sym

    end

    def json_attributes(name, *args)

      source_attributes, type = extract_attribute_data(name, *args)
      attribute = AttributeList.new(name, source_attributes, type)
      @attributes[to_s] ||= []
      @attributes[to_s] << attribute

      attr_accessor attribute.method_name.to_sym

    end

    def attributes
      @attributes[to_s] || []
    end

    def parse(data, options = {})

      # Parse the data into a hash
      json = JSON.parse(data, { :symbolize_names => true })

      # If we need to shift the structure, do that now
      shift = options.delete(:shift)
      unless shift.nil?
        shift = [ shift ] unless shift.is_a?(Array)
        shift.each do |s|
          break unless json.key?(s) # Break out if we can't find the element we're looking for
          json = json[s]
        end
      end

      # Parse the JSON data structure
      parse_json(json)

    end

    def parse_json(json)
      
      # Create a new instance of ourselves
      instance = new

      # Instantiate all AttributeList instances
      attributes.each do |attribute|
        if attribute.is_a?(AttributeList)
          instance.send("#{attribute.name}=", attribute.dup)
        end
      end

      # Traverse all defined attributes and assign data from the
      # JSON data structure
      attributes.each do |attribute|
        if is_mapped?(attribute, json)
          value = mapping_value(attribute, json)
          if attribute.is_a?(AttributeList)
            value = [ value ] unless value.is_a?(Array)
            value.each do |v|
              instance.send("#{attribute.name}") << build_attribute(attribute.name, attribute.type).typecast(v)
            end
          else
            instance.send("#{attribute.name}=".to_sym, attribute.typecast(value))
          end
        end
      end

      instance

    end

    private

    def build_attribute(name, type)
      Attribute.new(name, name, type)
    end

    def extract_attribute_data(name, *args)

      # If args is not an array, or it contains 0 elements,
      # throw an argument error as we at least need the data
      # type for the mapping specified.
      if !args.is_a?(Array) || args.empty?
        raise ArgumentError.new("Type parameter is required")
      end

      # If the first argument is a symbol or an array, that's
      # a specific source attribute mapping. If not, use the
      # specified name as the source attribute name.
      if args[0].is_a?(Symbol) || args[0].is_a?(Array)
        source_attributes = args.delete_at(0)
      else
        source_attributes = name
      end

      # The remaining first argument must be a valid data type
      if args[0].is_a?(Class)
        type = args[0]
      else
        raise ArgumentError.new("Invalid type parameter specified")
      end

      return source_attributes, type
 
    end

    def is_mapped?(attribute, json)

      attribute.source_attributes.each do |source_attribute|
        if json.key?(source_attribute)
          return true
        end
      end
      return false

    end

    def mapping_value(attribute, json)
      
      attribute.source_attributes.each do |source_attribute|
        if json.key?(source_attribute)
          return json[source_attribute]
        end
      end
      return nil

    end

  end

end

require "json_mapper/attribute"
require "json_mapper/attribute_list"
