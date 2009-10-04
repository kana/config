#!/usr/bin/env ruby




def main()
  ARGF.each_line do |line|
    puts line.sub('= ~', "= #{ENV['HOME']}")
  end
  return 0
end




if __FILE__ == $0
  exit main
end

__END__
