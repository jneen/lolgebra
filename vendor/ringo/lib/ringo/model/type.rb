module Ringo
  class Type
    class Error < TypeError; end

    def self.types
      @types ||= {}
    end

    def self.declare_with(*method_names)
      type_class = self
      method_names.each do |name|
        if self.types.include? name
          raise Error, "A type (#{Type.types[name]}) declared with :#{name} already exists!"
        end
        Type.types[name] = self

        # define the type methods on Model.  This allows
        # class Foo < Ringo::Model
        #   #{name} :bar
        # end
        # foo = Foo.new
        # foo.#{name} # => type.default
        # foo.#{name} = :something
        # foo.#{name} # => :something
        Model.meta_def name do |slug, *opts|
          slug = slug.to_sym
          fetch_slug = :"fetch_#{slug}"
          slug_equals = :"#{slug}="
          at_slug = "@#{slug}"
          type = type_class.new(*opts)

          define_method slug do
            self.instance_variable_get(at_slug) || self.send(fetch_slug)
          end

          define_method fetch_slug do
            key = key_for slug
            redis_val = redis.get(key)
            return self.instance_variable_set(at_slug, type.default) if redis_val.nil?
            instance_variable_set(at_slug, type.get_filter(redis_val))
          end

          define_method slug_equals do |val|
            key = self.key_for slug
            redis_val = type.set_filter(val)
            self.redis.set(key, redis_val)
            self.instance_variable_set(at_slug, type.get_filter(redis_val))
          end
        end

        Model.private_class_method(name)
      end
    end

    attr_reader :default

    def initialize(opts={})
      @default = opts[:default] || nil
    end
  end
end

require 'ringo/model/type/int.rb'
require 'ringo/model/type/string.rb'
require 'ringo/model/type/reference.rb'
