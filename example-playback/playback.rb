require 'patron'
require 'xampl'
require 'dirge'
require 'deja-vu' unless require ~'../lib/deja-vu'

player = SoldierOfCode::DejaVu::Player.new("bah7aa==
--ab7689c618445bb17b626741588b50c0500c8f79")
#player = SoldierOfCode::DejaVu::Player.new(ARGV[1])

puts player.play_frame().body
