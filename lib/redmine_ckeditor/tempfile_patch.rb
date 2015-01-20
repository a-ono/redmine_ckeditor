class Tempfile
  def initialize_with_binmode(basename, *rest)
    initialize_without_binmode(basename, *rest).tap do |f|
      f.binmode if basename == "raw-upload."
    end
  end

  alias_method_chain :initialize, :binmode
end
