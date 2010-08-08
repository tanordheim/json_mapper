require "test/unit"
require "shoulda"
require "matchy"
require "mocha"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require "json_mapper"

class Test::Unit::TestCase
end

# Load a fixture file and return the contents
def fixture_file(filename)
  
  return "" if filename == ""
  file_path = File.expand_path(File.dirname(__FILE__) + "/fixtures/" + filename)
  File.read(file_path)

end
