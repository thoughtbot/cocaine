class FakeLogger
  def initialize
    @entries = []
  end

  def info(text)
    @entries << text
  end

  def entries
    @entries
  end
end
