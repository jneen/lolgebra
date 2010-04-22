module Ringo
  class RedisType
    def redis
      Ringo.redis
    end

    def initialize(model, slug, options={})
      @model = model
      @slug = slug
      @type = Ringo.const_get(
        (options[:of] || :strings).singularize.camelcase
      )
    end

    def key
      @model.key_for(@slug)
    end

    def method_missing(meth, *args, &blk)
      @model.run_before_hooks(@slug, meth, *args, &blk)
      @redis_type.send(meth, *args, &blk)
      @model.run_after_hooks(@slug, meth, *args, &blk)
    end

    def self.declare_with(type_names)
      type = self
      type_names.each do |type_name|
        Model.meta_def type_name do |slug, *options|
          at_slug = :"@#{slug}"
          options = {} if options.empty?
          options = options.last if options.last.is_a? Hash
          
          define_method slug do
            return (
              instance_variable_get(at_slug) ||
              instance_variable_set(at_slug,
                type.new(self, slug, options)
              )
            )
          end
        end
      end
    end
  end
end

require 'ringo/model/redis_type/set.rb'
