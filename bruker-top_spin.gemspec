Gem::Specification.new do |s|
  s.name        = 'bruker-top_spin'
  s.version     = '0.0.1'
  s.date        = '2016-09-13'
  s.summary     = 'A set of classes for parsing Bruker TopSpin files in Ruby'
  # s.description = ''
  s.authors     = ['Scott Howland', 'Mark Borkum']
  s.email       = 'scott.howland@pnnl.gov'
  s.files       = ['lib/bruker.rb', 'lib/bruker/top_spin.rb', 'lib/bruker/top_spin/peak_list.rb', 'lib/bruker/top_spin/shifts.rb', 'lib/bruker/top_spin/t1_peaks.rb']
  s.test_files  = Dir.glob('test/test_*.rb')
  s.homepage    = 'https://github.com/EMSL-NMR-EPR/Ruby-Bruker-TopSpin-Library'
  s.license     = 'ECL-2.0'
  s.add_runtime_dependency 'nokogiri', '>= 1.6'
end
