module JSONMapper
  class Parser

    # Parse the JSON string into a Hash
    def self.parse(data)
      return nil if data.nil? || data == ""
      JSON.parse(data, { :symbolize_names => true })
    end

  end
end
