require "json"
require "haml"
contexts = JSON.parse(File.read(File.dirname(__FILE__) + "/tests.json"))

locals = {
  :var   => "value",
  :first => "a",
  :last  => "z"
}

contexts.each do |context|
  name = context[0]
  expectations = context[1]
  describe "When handling #{name}," do
    expectations.each do |input, expected|
      it "should render \"#{input}\" as \"#{expected}\"" do
        engine = Haml::Engine.new(input)
        engine.render(Object.new, locals).chomp.should == expected
      end
    end
  end
end


