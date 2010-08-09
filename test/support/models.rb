class SimpleModel

  include JSONMapper

  json_attribute :id, Integer
  json_attribute :money, Float
  json_attribute :title, String
  json_attribute :boolean, Boolean
  json_attribute :datetime, DateTime

end

class ComplexModel

  include JSONMapper

  json_attribute :id, [ :id, :attribute_id ], Integer
  json_attribute :model_title, :title, String
  json_attribute :datetime, DateTime
  json_attribute :simple, SimpleModel
  json_attribute :nested_test, { :nested => :test }, String
  json_attributes :simples, SimpleModel
  json_attributes :integers, Integer
  json_attributes :delimited, DelimitedString, :delimiter => ","

  json_attribute :self_referential, "self", SimpleModel

end
