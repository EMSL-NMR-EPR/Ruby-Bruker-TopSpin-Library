require 'minitest/autorun'

require 'bruker/top_spin'

class TestBrukerTopSpinT1Peaks < Minitest::Test
  def setup
    @filename = 'test/t1peaks.txt'
  end

  def test_read
    # Read the file named by +@filename+ and return a new +File+ object.
    #
    # The +File+ object will automatically be closed when the block terminates.
    File.open(@filename, 'r') { |file|
      # Read all bytes from the I/O stream.
      string = file.read
      
      # Parse Bruker TopSpin +t1peaks.txt+ document.
      bruker_top_spin_t1_peaks_text_document = Bruker::TopSpin::T1Peaks.Text(string)
      
      # Fails unless +bruker_top_spin_t1_peaks_text_document+ is an instance of +Bruker::TopSpin::T1Peaks::Text::Document+.
      assert_instance_of(Bruker::TopSpin::T1Peaks::Text::Document, bruker_top_spin_t1_peaks_text_document)
    }
  end
end
