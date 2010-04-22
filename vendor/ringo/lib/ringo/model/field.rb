module Ringo
  
  class Model
    def self.fields
      @fields ||= {}
    end

    def key_for(field)
      Ringo.key(:models, self.class.name.to_underscores, self.id, field)
    end

  end
end
