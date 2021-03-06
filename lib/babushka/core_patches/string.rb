class String
  # Return a DepRequirement that specifies the dep that should later be
  # called, and the arguments that should be passed. This allows requiring
  # deps with a less noisy syntax, and the lookup is lazy (it happens at the
  # point the dep is invoked, from its parent dep in Dep#run_requirements).
  #
  #   dep 'user has a password', :username do
  #     requires 'user exists'.with(username)
  #   end
  def with *args
    Babushka::DepRequirement.new(self, args)
  end

  # Returns true iff +other+ appears exactly at the start of +self+.
  def starts_with? other
    self[0, other.length] == other
  end

  # Returns true iff +other+ appears exactly at the end of +self+.
  def ends_with? other
    self[-other.length, other.length] == other
  end

  # Return a duplicate of +self+, with +other+ prepended to it if it doesn't already start with +other+.
  def start_with other
    starts_with?(other) ? self : other + self
  end

  # Return a duplicate of +self+, with +other+ appended to it if it doesn't already end with +other+.
  def end_with other
    ends_with?(other) ? self : self + other
  end

  # Extracts the value corresponding to the supplied key in an arbitrary,
  # multiline string. Most common config formats are handled. When there are
  # multiple matches, the first is returned. If there is no match, nil is
  # returned.
  #
  # See Array#val_for, and the cases in core_patches_spec.rb, for examples.
  def val_for key
    split("\n").val_for(key)
  end

  def / other
    (empty? ? other.p : (p / other))
  end

  # Create a VersionStr from this string.
  def to_version
    Babushka::VersionStr.new self
  end

  def colorized?
    self[/\e\[\d/]
  end

  # Return a new string with the contents of this string surrounded in escape
  # sequences such that it will render as described in +description+.
  # Some examples:
  #   'Hello world!'.colorize('green')   #=> "\e[0;32;29mHello world!\e[0m"
  #   'Hello world!'.colorize('on red')  #=> "\e[0;29;41mHello world!\e[0m"
  #   'Hello world!'.colorize('reverse') #=> "\e[0;29;7mHello world!\e[0m"
  def colorize description = '', start_at = nil
    if start_at.nil? || (cut_point = index(start_at)).nil?
      Colorizer.colorize self, description
    else
      self[0...cut_point] + Colorizer.colorize(self[cut_point..-1], description)
    end
  end

  # As +colorize+, but modify this string in-place instead of returning a new one.
  def colorize! description = nil, start_at = nil
    replace colorize(description, start_at) unless description.nil?
  end

  # Return a new string with all color-related escape sequences removed.
  def decolorize
    dup.decolorize!
  end

  # Remove all color-related escape sequences from this string in-place.
  def decolorize!
    gsub!(/\e\[\d+[;\d]*m/, '')
    self
  end
end
