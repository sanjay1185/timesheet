class OsFunctions
  
  # universal-darwin9.0 shows up for RUBY_PLATFORM on os X leopard with the bundled ruby. 
  # Installing ruby in different manners may give a different result, so beware.
  # Examine the ruby platform yourself. If you see other values please comment
  # in the snippet on dzone and I will add them.

  def self.is_mac?
    RUBY_PLATFORM.downcase.include?("darwin")
  end

  def self.is_windows?
     RUBY_PLATFORM.downcase.include?("mswin")
  end

  def self.is_linux?
     RUBY_PLATFORM.downcase.include?("linux")
  end
end