$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require "rubygems"
require "active_record"
require 'renum'
require 'haz_enum'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false

def setup_db
  ActiveRecord::Base.silence do
    ActiveRecord::Schema.define(:version => 1) do
      create_table :class_with_enums do |t|
        t.column :title, :string
        t.column :product, :string
        t.column :module_role, :string
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
      end

      create_table :class_with_custom_name_enums do |t|
        t.column :title, :string
        t.column :custom_name, :string
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
      end

      create_table :class_with_custom_name_fields do |t|
        t.column :title, :string
        t.column :main_product, :string
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
      end

      create_table :class_with_sets do |t|
        t.column :title, :string
        t.column :roles_bitfield, :integer
        t.column :roles_yml, :text
        t.column :module_roles_yml, :text
        t.column :extended_roles_yml, :text
        t.column :module_bitfield_roles_bitfield, :integer
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
      end

      create_table :class_with_custom_name_sets do |t|
        t.column :title, :string
        t.column :custom_name, :string
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
      end

    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

enum :Fakes, [:NOT_DEFINIED]
enum :Products, [:Silver, :Gold, :Titanium]
enum :Roles, [:Admin, :Supervisor, :User]

module ModuleRoles
  class Admin; def self.name; "Admin"; end; end
  class Supervisor; def self.name; "Supervisor"; end; end
  class ContentManager; def self.name; "ContentManager"; end; end
end

module ModuleBitfieldRoles
  class Admin
    def self.bitfield_index; 1; end
  end
  class Supervisor
    def self.bitfield_index; 2; end
  end
  class ContentManager
    def self.bitfield_index; 3; end
  end
  class <<self
    def values
      ModuleBitfieldRoles.constants.collect { |c| ModuleBitfieldRoles.const_get(c) }
    end
  end
end

setup_db # Init the database for class creation

class ClassWithEnum < ActiveRecord::Base
  has_enum :product
  has_enum :module_role
end

class ClassWithCustomNameEnum < ActiveRecord::Base
  has_enum :product, :column_name => :custom_name
end

class ClassWithCustomNameField < ActiveRecord::Base
  has_enum :main_product, :class_name => "Products"
end

class ClassWithSet < ActiveRecord::Base
  has_set :roles
  has_set :extended_roles, :class_name => :roles do
    def to_s
      extended_roles.collect(&:name).join(", ")
    end
  end
  has_set :module_roles
  has_set :module_bitfield_roles, :field_type => :bitfield
end

class YmlSet < ActiveRecord::Base
  self.table_name = "class_with_sets"
  has_set :roles, :field_type => :yml
end

class ClassWithCustomNameSet < ActiveRecord::Base
  has_set :roles, :column_name => :custom_name
end

teardown_db # And drop them right afterwards
