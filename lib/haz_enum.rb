require "haz_enum/enum"
require "haz_enum/set"

module HazEnum
  class <<self
    def available_field_types_for_sets
      [:yml, :bitfield]
    end
  end
end

ActiveRecord::Base.extend HazEnum::Enum
ActiveRecord::Base.extend HazEnum::Set