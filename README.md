# Bruker TopSpin

Bruker TopSpin is a library that provides a set of classes for parsing [Bruker TopSpin](https://www.bruker.com/products/mr/nmr/nmr-software/software/topspin/overview.html) files in Ruby.

* Read and write `peaklist.xml` documents using [Nokogiri](http://nokogiri.org/).

```ruby
require 'bruker/top_spin'
require 'nokogiri'

File.open('peaklist.xml', 'r') do |file|
  nokogiri_xml_document = Nokogiri.XML(file, nil, 'UTF-8')
  
  bruker_top_spin_peak_list_xml_document = Bruker::TopSpin::PeakList.XML(nokogiri_xml_document)
  
  # do something with +bruker_top_spin_peak_list_xml_document+ object
end
```

* Read `.shifts` documents.

```ruby
require 'bruker/top_spin'

File.open('example.shifts', 'r') do |file|
  string = file.read
  
  bruker_top_spin_shifts_tsv_table = Bruker::TopSpin::Shifts.TSV(string)
  
  # do something with +bruker_top_spin_shifts_tsv_table+ object
end
```

* Read `t1peaks.txt` documents.

```ruby
require 'rubygems'
require 'bruker/top_spin'

File.open('t1peaks.txt', 'r') do |file|
  string = file.read
  
  bruker_top_spin_t1_peaks_text_document = Bruker::TopSpin::T1Peaks.Text(string)
  
  # do something with +bruker_top_spin_t1_peaks_text_document+ object
end
```

## Download and installation

1. The latest version of Bruker TopSpin can be installed with RubyGems:

```bash
$ gem install bruker-top_spin
```

Source code can be downloaded as part of the Bruker TopSpin project on GitHub:

* [github.com/EMSL-NMR-EPR/Ruby-Bruker-TopSpin-Library](https://github.com/EMSL-NMR-EPR/Ruby-Bruker-TopSpin-Library)

# License

Bruker TopSpin is released under the ECL-2.0 license:

* [https://opensource.org/licenses/ECL-2.0](https://opensource.org/licenses/ECL-2.0)

# Support

Bug reports can be filed for the Bruker TopSpin project here:

* [github.com/EMSL-NMR-EPR/Ruby-Bruker-TopSpin-Library/issues](https://github.com/EMSL-NMR-EPR/Ruby-Bruker-TopSpin-Library/issues)
