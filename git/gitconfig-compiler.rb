#!/usr/bin/env ruby




def script_begin?(line)
  return line =~ /<<<$/
end

def script_end?(line)
  return line =~ />>>$/
end

def without_script_begin_marker(line)
  return line.sub /<<<\n/, ''
end




def main()
  context = :normal  # or :script

  ARGF.each_line do |line|
    if context == :normal
      if script_begin? line
        context = :script
        puts without_script_begin_marker(line) + %q["!f() {\\]
      else
        puts line.sub('= ~', "= #{ENV['HOME']}")
      end
    elsif context == :script
      if script_end? line
        context = :normal
        puts %Q[}; f"]
      else
        puts line.
          gsub("\\") {"\\\\"}.
          gsub('"') {'\"'}.
          sub("\n") {"\\n\\\n"}
      end
    else
      raise RuntimeError, "Invalid context #{context.inspect}"
    end
  end
  return 0
end




if __FILE__ == $0
  exit main
end

__END__
