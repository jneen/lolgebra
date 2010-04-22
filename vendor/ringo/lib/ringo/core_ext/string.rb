class String
  def to_underscores!
    self.downcase! #TODO
  end

  def to_underscores
    self.dup.to_underscores! #TODO
  end

  def to_camel_case!
    self.capitalize! #TODO
  end

  def to_camel_case
    self.dup.to_camel_case! #TODO
  end

  def pluralize(num=0)
    #TODO
    if num == 1
      self
    else
      self + 's'
    end
  end
end
