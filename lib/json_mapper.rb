require "json"

class Boolean; end
class DelimitedString; end

module JSONMapper

  def self.included(base)
    base.instance_variable_set("@attributes", {})
    base.instance_variable_set("@json_data", {})
    base.extend ClassMethods
  end

  module ClassMethods

    def json_attribute(name, *args)

      source_attributes, type, options = extract_attribute_data(name, *args)
      attribute = Attribute.new(name, source_attributes, type, options)
      @attributes[to_s] ||= []
      @attributes[to_s] << attribute

      attr_accessor attribute.method_name.to_sym

    end

    def json_attributes(name, *args)

      source_attributes, type, options = extract_attribute_data(name, *args)
      attribute = AttributeList.new(name, source_attributes, type, options)
      @attributes[to_s] ||= []
      @attributes[to_s] << attribute

      attr_accessor attribute.method_name.to_sym

    end

    def attributes
      @attributes[to_s] || []
    end

    def json_data
      @json_data[to_s] || []
    end

    def parse(data, options = {})

      return nil if data.nil? || data == ""
      json = get_json_structure(data, options)
      parse_json(json)

    end

    def parse_collection(data, options = {})

      return [] if data.nil? || data == ""
      json = get_json_structure(data, options)
      parse_json_collection(json)

    end

    def parse_json(json)

      # Set the JSON data for this instance
      @json_data[to_s] = json
      
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

              list_attribute = build_attribute(attribute.name, attribute.type, attribute.options)
              list_attribute_value = list_attribute.typecast(v)

              # Some times typecasting a value for a list will produce another list, in the case of
              # for instance DelimitedString. If this is the case, we concat that array to the list.
              # Otherwise, we just append the value.
              if list_attribute_value.is_a?(Array)
                instance.send("#{attribute.name}").concat(list_attribute_value)
              else
                instance.send("#{attribute.name}") << list_attribute_value
              end

            end
          else
            instance.send("#{attribute.name}=".to_sym, attribute.typecast(value))
          end
        end
      end

      instance

    end

    def parse_json_collection(json)

      collection = []

      if json.is_a?(Array)
        json.each do |element|
          collection << parse_json(element)
        end
      end

      collection

    end

    private

    def get_json_structure(data, options = {})
      
      # Parse the data into a hash
      json = Parser.parse(data)

      # If we need to shift the structure, do that now
      shift = options.delete(:shift)
      unless shift.nil?
        shift = [ shift ] unless shift.is_a?(Array)
        shift.each do |s|
          break unless json.key?(s) # Break out if we can't find the element we're looking for
          json = json[s]
        end
      end

      json

    end

    def build_attribute(name, type, options)
      Attribute.new(name, name, type, options)
    end

    def extract_attribute_data(name, *args)

      # If args is not an array, or it contains 0 elements,
      # throw an argument error as we at least need the data
      # type for the mapping specified.
      if !args.is_a?(Array) || args.empty?
        raise ArgumentError.new("Type parameter is required")
      end

      # If the first argument is a symbol, string or an array, that's
      # a specific source attribute mapping. If not, use the
      # specified name as the source attribute name.
      if args[0].is_a?(Symbol) || args[0].is_a?(Array) || args[0].is_a?(String) || args[0].is_a?(Hash)
        source_attributes = args.delete_at(0)
      else
        source_attributes = name
      end

      # The remaining first argument must be a valid data type
      if args[0].is_a?(Class)
        type = args.delete_at(0)
      else
        raise ArgumentError.new("Invalid type parameter specified")
      end

      # If we have anything remaining, and it's a hash, use it as our options
      options = {}
      if !args.empty? && args.first.is_a?(Hash)
        options = args.delete_at(0)
      end

      return source_attributes, type, options
 
    end

    def is_mapped?(attribute, json)

      # Just return true if this attribute is potentially self-referencing
      return true if attribute.self_referential?

      # Return false if our JSON isn't a hash or an array
      return false unless json.is_a?(Hash) || json.is_a?(Array)

      attribute.source_attributes.each do |source_attribute|

        # If the source attribute is a hash, do a key/value lookup on the json data
        if source_attribute.is_a?(Hash)

          source_key = source_attribute.keys.first
          if json.key?(source_key) && json[source_key].is_a?(Hash) && json[source_key].key?(source_attribute[source_key])
            return true
          end

        elsif json.key?(source_attribute)
          return true
        end
      end
      return false

    end

    def mapping_value(attribute, json)
      
      # Return nil if our JSON isn't a hash or an array
      return nil unless json.is_a?(Hash) || json.is_a?(Array)

      attribute.source_attributes.each do |source_attribute|
        
        # If the source attribute is a hash, do a key/value lookup on the json data
        if source_attribute.is_a?(Hash)

          source_key = source_attribute.keys.first
          if json.key?(source_key) && json[source_key].key?(source_attribute[source_key])
            return json[source_key][source_attribute[source_key]]
          end

         elsif json.key?(source_attribute)
          return json[source_attribute]
        end

      end

      # If no mapping could be found and this attribute is potentially
      # self-referencing, return the current JSON data as the mapped value
      return json_data if attribute.self_referential?

      return nil

    end

  end

end

require "json_mapper/parser"
require "json_mapper/attribute"
require "json_mapper/attribute_list"
