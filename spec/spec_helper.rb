$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'haz_enum'
require 'spec'
require 'spec/autorun'
require 'rubygems'
require 'active_record'
require 'renum'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false

def setup_db
  ActiveRecord::Base.silence do
    ActiveRecord::Schema.define(:version => 1) do
      create_table :class_with_enums do |t|
        t.column :title, :string
        t.column :product_enum_value, :string
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
      end

      create_table :class_without_enums do |t|
        t.column :title, :string
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
      end

      create_table :class_with_custom_name_enums do |t|
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

setup_db # Init the database for class creation

class ClassWithEnum < ActiveRecord::Base
  has_enum :product
end

class ClassWithoutEnum < ActiveRecord::Base; end

class ClassWithCustomNameEnum < ActiveRecord::Base
  has_enum :product, :column_name => :custom_name
end

teardown_db # And drop them right afterwards

Spec::Runner.configure do |config|
  
end
