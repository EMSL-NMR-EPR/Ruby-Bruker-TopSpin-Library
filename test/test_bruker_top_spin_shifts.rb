require 'minitest/autorun'

require 'bruker/top_spin'

class TestBrukerTopSpinShifts < Minitest::Test
  def setup
    @filename = 'test/ADP_3310.g03.shifts'
  end

  def test_read
    # Read the file named by +@filename+ and return a new +File+ object.
    #
    # The +File+ object will automatically be closed when the block terminates.
    File.open(@filename, 'r') { |file|
      # Read all bytes from the I/O stream.
      string = file.read
      
      # Parse Bruker TopSpin +*.shifts+ table.
      bruker_top_spin_shifts_tsv_table = Bruker::TopSpin::Shifts.TSV(string)
      
      # Fails unless +bruker_top_spin_shifts_tsv_table+ is an instance of +Bruker::TopSpin::Shifts::TSV::Table+.
      assert_instance_of(Bruker::TopSpin::Shifts::TSV::Table, bruker_top_spin_shifts_tsv_table)
    }
  end
end
