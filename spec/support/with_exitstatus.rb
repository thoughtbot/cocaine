module WithExitstatus
  def with_exitstatus_returning(code)
    saved_exitstatus = $?.nil? ? 0 : $?.exitstatus
    begin
      `ruby -e "exit #{code.to_i}"`
      yield
    ensure
      `ruby -e "exit #{saved_exitstatus.to_i}"`
    end
  end
end

