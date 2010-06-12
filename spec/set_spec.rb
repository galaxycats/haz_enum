require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "HazEnum" do
  
  describe "Set" do
    
    before(:all) do
      setup_db
    end
    
    it "should have class method has_enum" do
      ClassWithSet.should respond_to(:has_set)
    end
    
    it "should be able to set set-values via hash in initializer" do
      ClassWithSet.new(:roles => [Roles::User, Roles::Admin]).roles[0].should be(Roles::User)
      ClassWithSet.new(:roles => [Roles::User, Roles::Admin]).roles[1].should be(Roles::Admin)
    end
    
    it "should not be able to set set-values by colum-name via hash in initializer" do
      lambda { ClassWithEnum.new(:roles_bitfield => 3) }.should raise_error
    end
    
    it "colum_name should be configurable" do
      ClassWithCustomNameSet.new(:roles => [Roles::Admin]).roles.first.should be(Roles::Admin)
    end
    
    it "should know if set-attribute has changed" do
      roles_set = ClassWithSet.new(:roles => [Roles::Admin])
      roles_set.roles_changed?.should be(true)
      roles_set.save
      roles_set.roles_changed?.should be(false)
      roles_set.roles = [Roles::Supervisor]
      roles_set.roles_changed?.should be(true)
    end
  
    it "should know if enum-attribute has not really changed" do
      roles_set = ClassWithSet.new(:roles => [Roles::Admin])
      roles_set.save
      roles_set.roles = [Roles::Admin]
      roles_set.roles_changed?.should be(false)
    end
    
    it "should bea able to add set-value" do
      roles_set = ClassWithSet.new(:roles => [Roles::Admin])
      roles_set.save
      roles_set.roles << Roles::Supervisor
      roles_set.save
      roles_set.reload
      roles_set.has_role?(Roles::Admin).should == true
      roles_set.has_role?(Roles::Supervisor).should == true
    end
    
    after(:all) do
      teardown_db
    end
    
  end
end