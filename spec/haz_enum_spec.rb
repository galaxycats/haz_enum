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
  
  it "should have a enum_value attribute" do
    ClassWithEnum.new(:product => Products::Gold).product_enum_value.should be(Products::Gold.name)
  end
  
  it "colum_name should be configurable" do
    ClassWithCustomNameEnum.new(:product => Products::Gold).custom_name.should be(Products::Gold.name)
  end
  
  it "should know if enum-attribute has changed" do
    product_enum = ClassWithEnum.new(:product => Products::Silver)
    product_enum.product_changed?.should be(true)
    product_enum.save
    product_enum.product_changed?.should be(false)
    product_enum.product = Products::Gold
    product_enum.product_changed?.should be(true)
  end
  
  it "should know if enum-attribute has not really changed" do
    product_enum = ClassWithEnum.new(:product => Products::Silver)
    product_enum.save
    product_enum.product = Products::Silver
    product_enum.product_changed?.should be(false)
  end
  
  it "should validate enum-value" do
    enum_mixin = ClassWithEnum.new
    platin = "Platin"
    class <<platin; def name;"Platin";end;end
    enum_mixin.product = platin
    enum_mixin.valid?.should_not be(true)
    enum_mixin.errors[:product].size.should > 0
  end
  
  after(:all) do
    teardown_db
  end
end