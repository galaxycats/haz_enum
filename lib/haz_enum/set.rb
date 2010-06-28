module HazEnum
  module Set
    def has_set(set_name, options={})
      
      field_type = options.has_key?(:field_type) ? options[:field_type].to_s : "bitfield"
      set_column = options.has_key?(:column_name) ? options[:column_name].to_s : "#{set_name}_#{field_type}"
      enum_class = options.has_key?(:class_name) ? options[:class_name].to_s.camelize.constantize : set_name.to_s.camelize.constantize
      
      after_find "initialize_#{set_name}_from_bitfield"
      before_save "convert_#{set_name}_to_bitfield"
      
      enum_class.class_eval do
        def bitfield_index
          index + 1
        end
      end unless enum_class.method_defined?(:bitfield_index)
      
      define_method("#{set_name}") do
        instance_variable_get("@#{set_name}")
      end
      
      define_method("#{set_name}=") do |value|
        class <<value
          yield if block_given?
        end
        instance_variable_set("@#{set_name}", value)
      end
      
      define_method("has_#{set_name.to_s.singularize}?") do |set_value|
        send(set_name).include?(set_value)
      end
      
      define_method("#{set_name}_changed?") do
        send("convert_#{set_name}_to_bitfield")
        send("#{set_column}_changed?")
      end
      
      define_method("convert_#{set_name}_to_bitfield") do
        self[set_column] = 0
        if send(set_name)
          send(set_name).each do |element|
            2**element.bitfield_index & self[set_column] == 2**element.bitfield_index ? next : self[set_column] += 2**element.bitfield_index
          end
        end
      end

      define_method("initialize_#{set_name}_from_bitfield") do
        if self[set_column]
          set_elements = enum_class.values.collect do |enum_element|
            enum_element if ((2**enum_element.bitfield_index & self[set_column]) == 2**enum_element.bitfield_index)
          end.compact
          send("#{set_name}=", set_elements)
        else
          self[set_column] = 0
        end
      end
    end
  end
end