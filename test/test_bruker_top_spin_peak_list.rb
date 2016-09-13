require 'minitest/autorun'
require 'nokogiri'

require 'bruker/top_spin'

class TestBrukerTopSpinPeakList < Minitest::Test
  def setup
    @encoding = 'UTF-8'
    @filename = 'test/peaklist.xml'
  end

  def test_read
    # Read the file named by +@filename+ and return a new +File+ object.
    #
    # The +File+ object will automatically be closed when the block terminates.
    File.open(@filename, 'r') { |file|
      # Parse XML.
      document = Nokogiri.XML(file, nil, @encoding)
      
      # Parse Bruker TopSpin +peaklist.xml+ document.
      bruker_top_spin_peak_list_xml_document = Bruker::TopSpin::PeakList.XML(document)
      
      # Fails unless +bruker_top_spin_peak_list_xml_document+ is an instance of +Bruker::TopSpin::PeakList::XML::Document+.
      assert_instance_of(Bruker::TopSpin::PeakList::XML::Document, bruker_top_spin_peak_list_xml_document)
    }
  end
  
  def test_write
    # Read the file named by +@filename+ and return a new +File+ object.
    #
    # The +File+ object will automatically be closed when the block terminates.
    File.open(@filename, 'r') { |file|
      # Parse XML.
      document = Nokogiri.XML(file, nil, @encoding)
      
      # Parse Bruker TopSpin +peaklist.xml+ document.
      bruker_top_spin_peak_list_xml_document = Bruker::TopSpin::PeakList.XML(document)
      
      # Fails unless +bruker_top_spin_peak_list_xml_document+ is an instance of +Bruker::TopSpin::PeakList::XML::Document+.
      assert_instance_of(Bruker::TopSpin::PeakList::XML::Document, bruker_top_spin_peak_list_xml_document)
      
      # Convert +bruker_top_spin_peak_list_xml_document+ to XML.
      new_document = Nokogiri::XML::Document.new
      new_document.encoding = @encoding
      new_document.root = bruker_top_spin_peak_list_xml_document.to_xml(new_document)
      
      # Fails unless XML serializations of +document+ and +new_document+ are identical (note: not structurally equivalent).
      assert_equal(document.to_s, new_document.to_s)
    }
  end
end
