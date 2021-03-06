module HazEnum
  module Set
    def has_set(set_name, options={})
      
      field_type = options.has_key?(:field_type) ? options[:field_type].to_s : "yml"
      set_column = options.has_key?(:column_name) ? options[:column_name].to_s : "#{set_name}_#{field_type}"
      enum_class = options.has_key?(:class_name) ? options[:class_name].to_s.camelize.constantize : set_name.to_s.camelize.constantize
      separator = options.has_key?(:separator) ? options[:separator].to_s : ", "
      
      after_find "initialize_#{set_name}_from_#{field_type}"
      before_save "convert_#{set_name}_to_#{field_type}"
      
      define_method("#{set_name}") do
        instance_variable_get("@#{set_name}") || send("initialize_#{set_name}_from_#{field_type}")
      end
      
      define_method("#{set_name}=") do |value|
        value = [value].flatten
        value.collect! { |val| val.is_a?(String) ? val.constantize : val }.compact! if value.is_a?(Array)
        value.instance_variable_set("@separator", separator)
        class <<value
          define_method :human do
            self.collect do |enum|
              enum.respond_to?(:model_name) ? enum.model_name.human : enum.name
            end.join(@separator)
          end
          yield if block_given?
        end
        instance_variable_set("@#{set_name}", value)
      end
      
      define_method("has_#{set_name.to_s.singularize}?") do |set_value|
        send(set_name).include?(set_value)
      end
      
      define_method("#{set_name}_changed?") do
        send("convert_#{set_name}_to_#{field_type}")
        send("#{set_column}_changed?")
      end
      
      if field_type == "bitfield"
        
        enum_class.class_eval do
          def bitfield_index
            index + 1
          end
        end unless enum_class.method_defined?(:bitfield_index)
        
        define_method("convert_#{set_name}_to_bitfield") do
          self[set_column] = 0
          unless send(set_name).blank?
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
            send("#{set_name}=", [])
          end
        end

      elsif field_type == "yml"
        
        define_method("convert_#{set_name}_to_yml") do
          self[set_column] = YAML::dump(send(set_name))
        end

        define_method("initialize_#{set_name}_from_yml") do
          deserialized_value = (YAML::load(self[set_column] || "--- \n") || [])
          send("#{set_name}=", deserialized_value)
        end
        
      end
    end
  end
end