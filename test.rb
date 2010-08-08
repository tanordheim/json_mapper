module TestModule
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def foo
      attr_accessor :test
    end
  end
end

class TestClass
  include TestModule
  foo
end

t = TestClass.new
t.test = "test"
puts "Test is #{t.test}"

t2 = Class.new do
  include TestModule
  foo
end

t2.test = "foo"
puts "Test is #{t2.test}"
