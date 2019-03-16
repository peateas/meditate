# delay, rest, click, unit, group, turn, session, repeat
# noinspection RubyUnusedLocalVariable
default = [15, 1, 15, 60, 5, 3, 3, 1]
# noinspection RubyUnusedLocalVariable
quick = [1, 1, 1, 2, 2, 2, 2, 2]

# pick = quick
pick = default
pick = quick if ARGV[0]=='quick'
pick[pick.size-1] = ARGV[0].to_i if %w[1 2 3 4 5].include?(ARGV[0])
pick[pick.size-1] = ARGV[1].to_i if %w[1 2 3 4 5].include?(ARGV[1])

def play(sound)
  count = sound =~ /double/ ? 2 : 1
  filename = case sound.to_s
    when /tick/
      'Click2-Sebastian-759472264.mp3'
    when /ting/
      'Ting-sound-effect.mp3'
    when /bong/
      'Singing-bowl-sound.mp3'
    else
      raise "no sound #{sound}"
  end
  Thread.new do
    count.times do
      Thread.new do
        `vlc --qt-start-minimized --play-and-exit --qt-notification=0 #{filename}`
      end
      sleep(0.7)
    end
  end
end

def do_delay(delay, start)
  Thread.new do
    2.times do
      play(:ting)
      sleep(1)
    end
  end
  while Time.now < start + delay
    sleep(0.5)
  end
  play(:bong)
end

def time?(duration, interval, sound)
  return false unless (duration % interval).zero?

  play(sound)
  true
end

delay, rest, click, unit, group, turn, session, repeat = pick
group *= unit
turn *= group
session *= turn
puts "session:  #{session / 60}m; number:  #{repeat}"
puts "turn:  #{turn / 60}m; group:  #{group / 60}m; unit:  #{unit / 60}m"
delay_start = Time.now
puts "delay at #{delay_start}"
do_delay(delay, delay_start)
start = Time.now
puts "start at #{start} after #{(start - delay_start).to_i} seconds"
last = start
now = Time.now
units = 1
groups = 1
turns = 1
sessions = 1
while (now - start) <= (session * repeat)
  sleep(rest)
  now = Time.now
  duration = (now - last).to_i
  minutes = ((now - start) / 60).to_i
  message = "#{sessions}:#{turns}:#{groups}:#{units}:#{duration}:#{now}:#{minutes}m"
  puts message if (duration % click).zero?
  if (duration % session).zero?
    puts '**********'
  elsif (duration % turn).zero?
    puts '*****'
  elsif (duration % group).zero?
    puts '+++++'
  elsif (duration % unit).zero?
    puts '-----'
  end
  if time?(duration, session, :double_bong)
    units += 1
    groups += 1
    turns += 1
    sessions += 1
  elsif time?(duration, turn, :bong)
    units += 1
    groups += 1
    turns += 1
  elsif time?(duration, group, :double_ting)
    units += 1
    groups += 1
  elsif time?(duration, unit, :ting)
    units += 1
  elsif time?(duration, click, :tick)
  end
end
puts "end at #{Time.now}"
sleep(5)
# thread = Thread.new do
3.times do
  play(:ting)
  sleep(0.5)
end
# end
# thread.join
