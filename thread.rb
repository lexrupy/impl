require 'printer.rb'
t1 = Thread.new do
  5.times { x = rand(8); STDERR.print "\r\033[01;31mx\033[00m - -  1 => #{x}s"; sleep(x) }
end

t2 = Thread.new do
  5.times { x = rand(8); STDERR.print "\r- \033[01;32mx\033[00m -  2 => #{x}s"; sleep(x) }
end

t3 = Thread.new do
  5.times { x = rand(8); STDERR.print "\r- - \033[01;34mx\033[00m  3 => #{x}s"; sleep(x) }
end

t1.join
t2.join
t3.join

puts ""

