require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "HazEnum" do
  before(:all) do
    setup_db
  end
  
  it "should have class method has_enum" do
    ClassWithEnum.should respond_to(:has_enum)
  end
  
  it "should be able to set enum-attribute via hash in initializer" do
    ClassWithEnum.new(:product => Products::Silver).product.should be(Products::Silver)
  end
  
  it "should not be able to set enum-attribute by colum-name via hash in initializer" do
    ClassWithEnum.new(:product_enum_value => Products::Silver.name).product.should_not be(Products::Silver)
  end
  
  after(:all) do
    teardown_db
  end
end