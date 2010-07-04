require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "HazEnum" do
  
  describe "Enum" do
    
    before(:all) do
      setup_db
    end
    
    it "should have class method has_enum" do
      ClassWithEnum.should respond_to(:has_enum)
    end
    
    it "should be able to set enum-attribute via hash in initializer" do
      ClassWithEnum.new(:product => Products::Silver).product.should be(Products::Silver)
      ClassWithCustomNameEnum.new(:product => Products::Silver).product.should be(Products::Silver)
    end
    
    it "should be able to set enum-value as string in initializer" do
      ClassWithEnum.new(:product => "Silver").product.should be(Products::Silver)
    end
    
    it "should have has_<association>? method" do
      class_with_enum = ClassWithEnum.new(:product => "Silver")
      class_with_enum.has_product?(Products::Silver).should == true
      class_with_enum.has_product?(Products::Gold).should == false
    end
    
    it "should not be able to set enum-attribute by colum-name via hash in initializer" do
      ClassWithCustomNameEnum.new(:custom_name => Products::Silver).product.should_not be(Products::Silver)
      ClassWithCustomNameEnum.new(:custom_name => Products::Silver.name).product.should_not be(Products::Silver)
    end
    
    it "should have a enum_value attribute" do
      ClassWithCustomNameEnum.new(:product => Products::Gold).custom_name.should be(Products::Gold.name)
    end
    
    it "colum_name should be configurable" do
      ClassWithCustomNameEnum.new(:product => Products::Gold).product.should be(Products::Gold)
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
    
    it "should work without renum (just ruby module with classes)" do
      role_enum = ClassWithEnum.new(:module_role => ModuleRoles::Admin)
      role_enum.has_module_role?(ModuleRoles::Admin).should == true
    end
    
    after(:all) do
      teardown_db
    end
    
  end
end