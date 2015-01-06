YES = true
NO = false
NULL = nil
ZERO = 0

def pp(*args)
  puts "*** " + args.map(&:inspect).join(', ')
end

def ppx(label, *args)
  inspection = args.inspect[1...-1]
  inspection = ": #{inspection}" if inspection.present?
  puts "--- #{label}#{inspection}"
end
