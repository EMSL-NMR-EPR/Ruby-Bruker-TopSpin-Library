module Bruker
  module TopSpin
    ###
    # Bruker TopSpin (version 2.1 or newer) "t1peaks.txt" documents.
    module T1Peaks
      ###
      # Parse a T1 peaks document (encoded as a string).
      #
      # @param string [String] a string
      # @return [Bruker::TopSpin::T1Peaks::Text::Document, nil] representation of a T1 peaks table (on success), or +nil+ (on failure)
      # @raise [Bruker::TopSpin::T1Peaks::Text::InvalidFirstLineError]
      # @raise [Bruker::TopSpin::T1Peaks::Text::InvalidMiddleLinesError]
      # @raise [Bruker::TopSpin::T1Peaks::Text::InvalidLastLineError]
      # @raise [Bruker::TopSpin::T1Peaks::Text::InvalidLinesCountError]
      # @raise [Bruker::TopSpin::T1Peaks::Text::InvalidSliceError]
      def self.Text(string)
        first_line, *middle_lines, last_line = *string.to_s.split(/\r?\n/)
    
        lines_count = begin
          array_of_fixnum = first_line.split(/\s+/).collect(&:to_i)
        
          n = if (array_of_fixnum.size == 1) && array_of_fixnum.none?(&:nil?)
            array_of_fixnum.first
          else
            raise Bruker::TopSpin::T1Peaks::Text::InvalidFirstLineError.new(first_line)
          end
        
          if ((n - 1) % 3) == 0
            n
          else
            raise Bruker::TopSpin::T1Peaks::Text::InvalidLinesCountError.new(n)
          end
        end
    
        begin
          array_of_fixnum = last_line.split(/\s+/).collect(&:to_i)
        
          if array_of_fixnum == [-1, 0, 0]
            nil
          else
            raise Bruker::TopSpin::T1Peaks::Text::InvalidLastLineError.new(last_line)
          end
        end
    
        array_of_array_of_fixnum_or_float = middle_lines.collect { |line| line.split(/\s+/) }
      
        if array_of_array_of_fixnum_or_float.size.divmod(3) == [(lines_count - 1) / 3, 0]
          t1_peaks = array_of_array_of_fixnum_or_float.each_slice(3).inject([]) do |acc, slice|
            xs, ys, zs = *slice
      
            x0, x1, x2 = *xs
            y0, y1, y2 = *ys
            z0, z1, z2 = *zs
      
            if !(number = x0.to_i).nil? && !(intensity = z1.to_f).nil?
              acc << Bruker::TopSpin::T1Peaks::Text::T1Peak.new(number, intensity)
              acc
            else
              raise Bruker::TopSpin::T1Peaks::Text::InvalidSliceError.new(slice)
            end
          end
    
          Bruker::TopSpin::T1Peaks::Text::Document.new(t1_peaks)
        else
          raise Bruker::TopSpin::T1Peaks::Text::InvalidMiddleLinesError.new(middle_lines)
        end
      end
    
      module Text
        ###
        # Raised unless the first line in "t1peaks.txt" is a non-negative integer.
        #
        # @!attribute [r] string
        #   @return [String] the first line of "t1peaks.txt"
        class InvalidFirstLineError < RuntimeError
          attr_reader :string
        
          def initialize(string)
            @string = string
          end
        end

        ###
        # Raised unless the total number of middle lines in "t1peaks.txt" is
        # equal to the declared number of lines, minus 1, divided by 3.
        #
        # @!attribute [r] array_of_string
        #   @return [Array<String>] the middle lines of "t1peak.txt"
        class InvalidMiddleLinesError < RuntimeError
          attr_reader :array_of_string

          def initialize(array_of_string = [])
            @array_of_string = array_of_string
          end
        end

        ###
        # Raised unless the last line in "t1peaks.txt" is equal to "-1 0 0".
        #
        # @!attribute [r] string
        #   @return [String] the last line of "t1peaks.txt"
        class InvalidLastLineError < RuntimeError
          attr_reader :string
        
          def initialize(string)
            @string = string
          end
        end

        ###
        # Raised unless the declared number of lines in "t1peaks.txt" is a
        # non-negative integer multiple of 3.
        #
        # @!attribute [r] lines_count
        #   @return [Fixnum] the declared number of lines in "t1peaks.txt"
        class InvalidLinesCountError < RuntimeError
          attr_reader :lines_count

          def initialize(lines_count)
            @lines_count = lines_count
          end
        end

        ###
        # Raised unless the slice is well-formed (i.e., a 3x3 matrix).
        #
        # @!attribute [r] slice
        #   @return [Array<Array<String>>] a 3x3 matrix
        class InvalidSliceError < RuntimeError
          attr_reader :slice
        
          def initialize(slice = [])
            @slice = slice
          end
        end

        ###
        # Abstract representation of a T1 peaks document.
        #
        # @!attribute [rw] t1peaks
        #   @return [Array<Bruker::Shifts::TSV::Row>] the list of T1 peaks for this document
        Document = Struct.new(:t1_peaks)

        ###
        # Abstract representation of a T1 peak.
        #
        # @!attribute [rw] number
        #   @return [Fixnum] the number of the T1 peak
        # @!attribute [rw] intensity
        #   @return [String] the intensity of the T1 peak (units: 1)
        T1Peak = Struct.new(:number, :intensity)
      end
    end
  end
end
