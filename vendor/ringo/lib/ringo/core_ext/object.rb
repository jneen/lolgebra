class Object
  def metaclass
    class << self
      self
    end
  end

  def meta_eval(&blk)
    self.metaclass.class_eval &blk
  end

  def meta_def(name, &blk)
    self.meta_eval { define_method(name, &blk) }
  end
end
