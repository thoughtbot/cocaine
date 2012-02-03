module StubOS
  def on_windows!
    stub_os('mswin')
  end

  def on_unix!
    stub_os('darwin11.0.0')
  end

  def on_mingw!
    stub_os('mingw')
  end

  def stub_os(host_string)
    # http://blog.emptyway.com/2009/11/03/proper-way-to-detect-windows-platform-in-ruby/
    RbConfig::CONFIG.stubs(:[]).with('host_os').returns(host_string)
  end
end
