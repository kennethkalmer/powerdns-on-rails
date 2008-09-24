require File.dirname(__FILE__) + '/../spec_helper'

describe AuditsHelper do
  
  it "should have a way to display the changes hash with blank stipped" do
    result = display_hash( 'key' => 'value', :blank => nil )
    result.should eql("<em>key</em>: value")
  end
  
  it "should seperate items in the change hash with breaks" do
    result = display_hash( 'one' => 'one', 'two' => 'two' )
    result.should eql("<em>two</em>: two<br /><em>one</em>: one")
  end
  
end
