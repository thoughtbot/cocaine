module StubOS
  def on_windows!(host_string = 'mswin')
    stub_os(host_string)
  end

  def on_unix!(host_string = 'darwin11.0.0')
    stub_os(host_string)
  end

  def stub_os(host_string)
    # http://blog.emptyway.com/2009/11/03/proper-way-to-detect-windows-platform-in-ruby/
    Config::CONFIG.stubs(:[]).with('host_os').returns(host_string)
  end
end
