module HazEnum
  module Enum
    def has_enum(enum_name, options={})
      enum_column = options.has_key?(:column_name) ? options[:column_name].to_s : "#{enum_name}_enum_value"
      # throws a NameError if Enum Class doesn't exists
      enum_class = options.has_key?(:class_name) ? Object.const_get(options[:class_name].to_s.classify) : Object.const_get(enum_name.to_s.pluralize.camelize)
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        attr_protected :#{enum_column}
        validate :#{enum_column}_check_for_valid_enum_value
        def #{enum_name}
          begin
            return #{enum_class}.const_get(self["#{enum_column}"]) if self["#{enum_column}"]
            return nil
          rescue NameError => e
            return nil
          end
        end
      
        def #{enum_name}=(enum_to_set)
          self["#{enum_column}"] = enum_to_set.name
        end
              
        def #{enum_name}_changed?
          send("#{enum_column}_changed?")
        end
        
        def #{enum_column}_check_for_valid_enum_value
          return true if self["#{enum_column}"].nil?
          begin
            #{enum_class}.const_get(self["#{enum_column}"])
          rescue NameError => e
            self.errors.add("#{enum_name}".to_sym, I18n.t("activerecord.errors.messages.enum_value_invalid", :value => self["#{enum_column}"], :name => "#{enum_name}"))
          end
        end
        
      RUBY
    end
    
  end
end