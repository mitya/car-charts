YES = true
NO = false
NULL = nil
ZERO = 0

def pp(*args)
  puts "*** " + args.map(&:inspect).join(', ')
end

def __assert(condition)
  raise unless condition
end

def __p(label, *args)
  inspection = ": #{args.inspect[1...-1]}" if args.any?
  puts "--- #{label}#{inspection}"
end

alias __P __p

def __pla(array)
  array.each do |item|
    puts "--- #{item.inspect}"
  end
  nil
end
