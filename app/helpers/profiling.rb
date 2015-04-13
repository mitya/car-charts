CC_BENCHMARKING = KK.env?('CCBenchmarking')
$es_profiling_time = nil
$es_profiling_results = []

# KK.profileBegin
# KK.profilePrint("action")
# 
# KK.profileBegin("Title")
# KK.profile("action name")
# KK.profileEnd("last action name")

module Profiling
  def profileBegin(title = nil)
    $es_profiling_title = title
    $es_profiling_results = []
    $es_profiling_time = Time.now
  end

  def profilePrint(label)
    elapsed = (Time.now - $es_profiling_time) * 1_000
    NSLog("TIMING #{$es_profiling_title} #{label}: #{"%.3f" % elapsed}ms")
    $es_profiling_time = Time.now
  end

  def profile(label)
    elapsed = (Time.now - $es_profiling_time) * 1_000
    $es_profiling_results << [label, elapsed]
    $es_profiling_time = Time.now
  end

  def profileEnd(label = nil)
    profile(label) if label
    text = $es_profiling_results.map { |label, time| "#{label} %.3f" % time }.join(', ')
    # text = $es_profiling_results.map { |label, time| "%s %.3f" % [label, time] }.join(', ') # MEMORY BUG
    NSLog("TIMING #{$es_profiling_title} #{text}")
  end    
end

KK.extend(KK::Profiling)