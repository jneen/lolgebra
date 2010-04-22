class Symbol
  def /(other)
    :"#{self}/#{other}"
  end

  def +(other)
    :"#{self}#{other}"
  end
end
