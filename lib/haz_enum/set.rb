module HazEnum
  module Set
    def has_set(set_name, options={})
      
      field_type = options.has_key?(:field_type) ? options[:field_type].to_s : "bitfield"
      set_column = options.has_key?(:column_name) ? options[:column_name].to_s : "#{set_name}_#{field_type}"
      enum_class = options.has_key?(:class_name) ? Object.const_get(options[:class_name].to_s.classify) : Object.const_get(set_name.to_s.camelize)
      
      self.before_save "convert_#{set_name}_to_bitfield"
      
      define_method("#{set_name}") do
        instance_variable_get("@#{set_name}")
      end
      
      define_method("#{set_name}=") do |new_elements|
        instance_variable_set("@#{set_name}", new_elements)
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
        self[set_column] = send(set_name).each do |element|
          2**element.index & self[set_column] == 2**element.index ? next : self[set_column] += 2**element.index
        end
      end
    end
  end
end