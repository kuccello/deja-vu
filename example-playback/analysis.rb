require 'patron'
require 'xampl'
require 'dirge'
require 'deja-vu' unless require ~'../lib/deja-vu'

analyzer = SoldierOfCode::DejaVu::Analyzer.new
analyzer.overview_formatted
