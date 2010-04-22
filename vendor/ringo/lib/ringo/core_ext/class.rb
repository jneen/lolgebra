class Class
  def descends_from?(klass)
    return false if self.superclass.nil?
    (self == klass) || self.superclass.descends_from?(klass)
  end
end
