module Bruker
  ###
  # Bruker TopSpin
  #
  # @see https://www.bruker.com/products/mr/nmr/nmr-software/software/topspin/overview.html
  module TopSpin
    autoload :PeakList, 'bruker/top_spin/peak_list'
    autoload :Shifts,   'bruker/top_spin/shifts'
    autoload :T1Peaks,  'bruker/top_spin/t1_peaks'
  end
end
