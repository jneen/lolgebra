module Ringo
  class RedisType
    def redis
      Ringo.redis
    end

    def initialize(model, slug, type, options={})
      @model = model
      @slug = slug
      @type = type
    end

    def key
      @model.key_for(@slug)
    end

    def self.declare_with(*type_names)
      redis_type = self
      type_names.each do |type_name|
        Model.meta_def type_name do |slug, options|
          at_slug = :"@#{slug}"
          options = {} if options.empty?
          type = Ringo::Type.types[
            (options[:of] || :strings).to_s.singularize.to_sym
          ].new(options)
          
          define_method slug do
            return (
              instance_variable_get(at_slug) ||
              instance_variable_set(at_slug,
                redis_type.new(self, slug, type, options)
              )
            )
          end
        end
      end
    end
  end
end

require 'ringo/model/redis_type/list.rb'
