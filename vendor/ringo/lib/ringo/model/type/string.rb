module Ringo
  class RingoString < Type
    declare_with :str, :string
    def get_filter(val)
      val.to_s
    end

    def set_filter(val)
      val.to_s
    end
  end
end
