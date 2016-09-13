require 'csv'

module Bruker
  module TopSpin
    ###
    # Bruker TopSpin (version 2.1 or newer) "*.shifts" documents.
    module Shifts
      ###
      # Parse a TSV table (encoded as a string).
      #
      # @param string [String] a string
      # @return [Bruker::TopSpin::Shifts::TSV::Table, nil] representation of a TSV table (on success), or +nil+ (on failure)
      # @raise [CSV::MalformedCSVError]
      def self.TSV(string)
        rows = []

        CSV.parse(string, :col_sep => "\t", :headers => true, :return_headers => false) { |row|
          number = if !(field = row.field('number')).nil?
            field.to_i
          else
            nil
          end

          atom = if !(field = row.field('atom')).nil?
            field.to_s
          else
            nil
          end

          shift = if !(field = row.field('shift')).nil?
            shift.to_f
          else
            nil
          end

          rows << Bruker::TopSpin::Shifts::TSV::Row.new(number, atom, shift)
        }

        Bruker::TopSpin::Shifts::TSV::Table.new(rows)
      end

      module TSV
        ###
        # Abstract representation of a TSV table.
        #
        # @!attribute [rw] rows
        #   @return [Array<Bruker::TopSpin::Shifts::TSV::Row>] the list of rows for this table
        Table = Struct.new(:rows)

        ###
        # Abstract representation of a TSV row.
        #
        # @!attribute [rw] number
        #   @return [Fixnum] the number of the assigned atom
        # @!attribute [rw] atom
        #   @return [String] the chemical element of the assigned atom
        # @!attribute [rw] shift
        #   @return [Float] the chemical shift (units: ppm)
        Row = Struct.new(:number, :atom, :shift)
      end
    end
  end
end
