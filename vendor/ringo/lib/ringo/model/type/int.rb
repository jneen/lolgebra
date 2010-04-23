module Ringo
  class RingoIntegerType < Type
    declare_with :int, :integer
    def get_filter(val)
      val.to_i
    end

    def set_filter(val)
      val.to_i.to_s
    end
  end
end
