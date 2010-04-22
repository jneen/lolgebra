module Ringo
  class Reference < Type
    declare_with :reference
    class Error < Type::Error; end
    def initialize(opts)
      unless opts.include? :to
        raise Error, "Reference doesn't know what to reference!"
      end

      @reference = Ringo.const_get(opts[:to].to_s.camelcase)

      unless @reference.descends_from? Ringo::Model
        p @reference.superclass
        raise Error, "Reference expected #{@reference.inspect} to be a Ringo::Model!"
      end

      super
    end

    def get_filter(val)
      @reference[val.to_i]
    end

    def set_filter(val)
      unless val.is_a? @reference
        raise Error, "Ringo::Reference expected #{val.inspect} to be a #{@reference}."
      end
      val.id
    end
  end
end
