module Ringo
  class Model

    ## class methods
    class << self
      def field_type(name, klass)
        meta_def(name) do |slug, *options|
          self.fields[slug] = klass.new(self, slug, *options)
        end
      end

      def find(id)
        self.new(:id => id)
      end
      alias [] find

      def slug
        self.name.underscore.pluralize
      end

      def key(*args)
        Ringo.key(self.slug, *args)
      end

      def last_id
        Ringo.redis[self.key('__id__')].to_i
      end
    end


    ## instance methods

    def initialize(attrs={})
      if attrs.include? :id
        @id = attrs[:id].to_i
        attrs.delete :id
      end

      attrs.each do |slug, val|
        #if self.class.fields.include? slug
          self.send(:"#{slug}=", val)
        #end
      end
    end

    def id
      @id ||= redis.incr(self.class.key('__id__')).to_i
    end

    def ==(other)
      self.class == other.class &&
      self.id == other.id
    end

    def save!
      self.class.fields.map do |slug, field|
        if (val = instance_variable_get("@#{slug}"))
          field.save!(slug, val)
        end
      end
    end

    #helper method to reduce typing :D
    def self.redis
      Ringo.redis
    end

    def redis
      self.class.redis
    end

  end
end
