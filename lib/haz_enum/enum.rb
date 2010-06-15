module HazEnum
  module Enum
    def has_enum(enum_name, options={})
      enum_name = enum_name.to_s
      enum_column = options.has_key?(:column_name) ? options[:column_name].to_s : enum_name
      enum_class = options.has_key?(:class_name) ? Object.const_get(options[:class_name].to_s.classify) : Object.const_get(enum_name.pluralize.camelize)
      
      self.attr_protected("#{enum_column}") if enum_name != enum_column
      self.validate "#{enum_column}_check_for_valid_enum_value"
      
      define_method "#{enum_name}" do
        begin
          return enum_class.const_get(self["#{enum_column}"]) if self["#{enum_column}"]
          return nil
        rescue NameError => e
          return nil
        end
      end
      
      define_method "#{enum_name}=" do |enum_to_set|
        self["#{enum_column}"] = enum_to_set.name
      end
      
      define_method "#{enum_name}_changed?" do
        send("#{enum_column}_changed?")
      end if enum_name != enum_column
      
      define_method "#{enum_column}_check_for_valid_enum_value" do
        return true if self["#{enum_column}"].nil?
        begin
          enum_class.const_get(self["#{enum_column}"])
        rescue NameError => e
          self.errors.add("#{enum_name}".to_sym, I18n.t("activerecord.errors.messages.enum_value_invalid", :value => self["#{enum_column}"], :name => enum_name))
        end
      end
    end
  end
end