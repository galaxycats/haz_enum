module HazEnum
  module Enum
    def has_enum(enum_name, options={})
      enum_name = enum_name.to_s
      enum_column = options.has_key?(:column_name) ? options[:column_name].to_s : enum_name
      enum_class = options.has_key?(:class_name) ? options[:class_name].constantize : enum_name.pluralize.camelize.constantize

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
        if enum_to_set.blank?
          self["#{enum_column}"] = nil
        elsif enum_to_set.respond_to?(:name)
          self["#{enum_column}"] = enum_to_set.name
        else
          self["#{enum_column}"] = enum_class.const_get(enum_to_set).name
        end
      end

      define_method "has_#{enum_name}?" do |enum|
        send(enum_name) == enum
      end

      define_method "#{enum_name}_changed?" do
        send("#{enum_column}_changed?")
      end if enum_name != enum_column

      define_method "#{enum_column}_check_for_valid_enum_value" do
        return true if self["#{enum_column}"].nil?
        begin
          enum_class.const_get(self["#{enum_column}"])
        rescue NameError => e

          message = I18n.translate("activerecord.errors.models.#{self.class.name.underscore}.attributes.#{enum_name}.enum_value_invalid", :value => self["#{enum_column}"], :name => enum_name) ||
                    I18n.translate("activerecord.errors.models.#{self.class.name.underscore}.enum_value_invalid", :value => self["#{enum_column}"], :name => enum_name) ||
                    I18n.translate(:'activerecord.errors.messages.enum_value_invalid', :value => self["#{enum_column}"], :name => enum_name)

          self.errors.add(enum_name.to_sym, message)
        end
      end
    end
  end
end
