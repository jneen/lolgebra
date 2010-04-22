module Ringo
  class Model
    class << self
      def before (slug, options, &blk)
        return unless block_given?
        meth = options[:recieves] || options[:is]
        self.before_hooks[[slug,meth]] ||= Set.new
        self.before_hooks[[slug,meth]].add blk
      end

      def before_hooks
        @before_hooks ||= {}
      end

      def run_before_hooks(slug, meth, *args, &blk)
        if (hooks = self.before_hooks[[slug,meth]])
          hooks.each { |h| h.call(*args, &blk) }
        end
      end

      def after (slug, options, &blk)
        return unless block_given?
        meth = options[:recieves] || options[:is]
        self.after_hooks[[slug,meth]] ||= Set.new
        self.after_hooks[[slug,meth]].add blk
      end

      def after_hooks
        @after_hooks ||= {}
      end

      def run_after_hooks(slug, meth, *args, &blk)
        if (hooks = self.after_hooks[[slug,meth]])
          hooks.each { |h| h.call(*args, &blk) }
        end
      end
    end

    end
  end
end
