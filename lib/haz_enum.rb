require "active_record"
require "haz_enum/enum"
require "haz_enum/set"

module HazEnum
end

ActiveRecord::Base.extend HazEnum::Enum
ActiveRecord::Base.extend HazEnum::Set