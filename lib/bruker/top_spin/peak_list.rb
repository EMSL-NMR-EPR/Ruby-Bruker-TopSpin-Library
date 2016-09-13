require 'date'
require 'nokogiri'

module Bruker
  module TopSpin
    ###
    # Bruker TopSpin (version 2.1 or newer) "peaklist.xml" documents.
    module PeakList
      ###
      # Alias for +Bruker::TopSpin::PeakList::XML::Document.parse(document)+.
      #
      # @param document [Nokogiri::XML::Document] an XML document
      # @return [Bruker::TopSpin::PeakList::XML::Document, nil] representation of an XML document (on success), or +nil+ (on failure)
      def self.XML(document)
        Bruker::TopSpin::PeakList::XML::Document.parse(document)
      end

      module XML
        ###
        # Template for parsing representation of date and time.
        #
        # @return [String]
        DATETIME_FORMAT = '%Y-%m-%dT%H:%M:%S'.freeze

        ###
        # Abstract representation of an XML node.
        class Node
          class << self
            ###
            # Parse an XML document.
            #
            # @param document [Nokogiri::XML::Document] an XML document
            # @return [Bruker::TopSpin::PeakList::XML::Node, nil] representation of an XML node (on success), or +nil+ (on failure)
            def parse(document)
              raise NotImplementedError
            end
          end

          ###
          # Default constructor.
          def initialize
            super
          end

          ###
          # Create a new XML node sharing GC lifecycle with +document+.
          #
          # @param document [Nokogiri::XML::Document] an XML document
          # @return [Nokogiri::XML::Node] a new XML node (on success), or +nil+ (on failure)
          def to_xml(document)
            raise NotImplementedError
          end
        end

        ###
        # Abstract representation of an XML document.
        #
        # @!attribute [rw] root
        #   @return [Bruker::TopSpin::PeakList::XML::Nodes::PeakList] the root +<PeakList>+ XML node for this XML document
        class Document < Bruker::TopSpin::PeakList::XML::Node
          class << self
            ###
            # Parse an XML document.
            #
            # @param document [Nokogiri::XML::Document] an XML document
            # @return [Bruker::TopSpin::PeakList::XML::Document, nil] representation of an XML document (on success), or +nil+ (on failure)
            def parse(document)
              return nil if document.nil?

              if !(root = document.root).nil? && !(result = Bruker::TopSpin::PeakList::XML::Nodes::PeakList.parse(root)).nil?
                new(result)
              else
                nil
              end
            end
          end

          attr_accessor :root

          ###
          # Default constructor
          #
          # @param root [Bruker::TopSpin::PeakList::XML::Nodes::PeakList] the root +<PeakList>+ XML node for this XML document
          def initialize(root)
            super()

            @root = root
          end

          ###
          # Create a new XML document (as a new +<PeakList>+ XML node) sharing GC lifecycle with +document+.
          #
          # @param document [Nokogiri::XML::Document] an XML document
          # @return [Nokogiri::XML::Node] a new +<PeakList>+ XML node (on success), or +nil+ (on failure)
          def to_xml(document)
            @root.to_xml(document)
          end
        end

        ###
        # Subclasses of +Bruker::TopSpin::PeakList::XML::Node+.
        module Nodes
          ###
          # Representation of +<PeakList>+ XML node.
          #
          # @!attribute [rw] modified
          #   @return [DateTime] the date and time that this +<PeakList>+ XML node was modified
          # @!attribute [rw] children
          #   @return [Array<Bruker::TopSpin::PeakList::XML::Nodes::PeakList1D>] the list of children of this +<PeakList>+ XML node
          class PeakList < Bruker::TopSpin::PeakList::XML::Node
            class << self
              ###
              # Parse an XML document.
              #
              # @param document [Nokogiri::XML::Document] an XML document
              # @return [Bruker::TopSpin::PeakList::XML::Nodes::PeakList, nil] representation of +<PeakList>+ XML node (on success), or +nil+ (on failure)
              def parse(document)
                return nil if document.nil?
                return nil unless document.name == 'PeakList'

                modified = if !(attribute = document.attribute('modified')).nil?
                  DateTime.strptime(attribute.value.to_s, Bruker::TopSpin::PeakList::XML::DATETIME_FORMAT)
                else
                  nil
                end

                children = document.xpath('PeakList1D').collect { |node|
                  Bruker::TopSpin::PeakList::XML::Nodes::PeakList1D.parse(node)
                }

                new(modified, children)
              end
            end

            attr_accessor :modified, :children

            ###
            # Default constructor.
            #
            # @param modified [DateTime] the date and time that this +<PeakList>+ XML node was modified
            # @param children [Array<Bruker::TopSpin::PeakList::XML::Nodes::PeakList1D>] the list of children of this +<PeakList>+ XML node
            def initialize(modified, children = [])
              super()

              @modified = modified

              @children = children
            end

            ###
            # Create a new +<PeakList>+ XML node sharing GC lifecycle with +document+.
            #
            # @param document [Nokogiri::XML::Document] an XML document
            # @return [Nokogiri::XML::Node] a new +<PeakList>+ XML node (on success), or +nil+ (on failure)
            def to_xml(document)
              node = Nokogiri::XML::Node.new('PeakList', document)

              node.set_attribute('modified', @modified.respond_to?(:strftime) ? @modified.strftime(Bruker::TopSpin::PeakList::XML::DATETIME_FORMAT) : nil)

              @children.each do |child|
                node << child.to_xml(document)
              end

              node
            end
          end

          ###
          # Representation of +<PeakList1D>+ XML node.
          #
          # @!attribute [rw] header
          #   @return [Bruker::TopSpin::PeakList::XML::Nodes::PeakList1DHeader] the header for this +<PeakList1D>+ XML node
          # @!attribute [rw] children
          #   @return [Array<Bruker::TopSpin::PeakList::XML::Nodes::Peak1D>] the list of children of this +<PeakList>+ XML node
          class PeakList1D < Bruker::TopSpin::PeakList::XML::Node
            class << self
              ###
              # Parse an XML document.
              #
              # @param document [Nokogiri::XML::Document] an XML document
              # @return [Bruker::TopSpin::PeakList::XML::Nodes::PeakList1D, nil] representation of +<PeakList1D>+ XML node (on success), or +nil+ (on failure)
              def parse(document)
                return nil if document.nil?
                return nil unless document.name == 'PeakList1D'

                header = document.xpath('PeakList1DHeader').collect { |node|
                  Bruker::TopSpin::PeakList::XML::Nodes::PeakList1DHeader.parse(node)
                }.first

                children = document.xpath('Peak1D').collect { |node|
                  Bruker::TopSpin::PeakList::XML::Nodes::Peak1D.parse(node)
                }

                new(header, children)
              end
            end

            attr_accessor :header, :children

            ###
            # Default constructor.
            #
            # @param header [Bruker::TopSpin::PeakList::XML::Nodes::PeakList1DHeader] the header for this +<PeakList1D>+ XML node
            # @param children [Array<Bruker::TopSpin::PeakList::XML::Nodes::Peak1D>] the list of children of this +<PeakList>+ XML node
            def initialize(header, children = [])
              super()

              @header = header

              @children = children
            end

            ###
            # Create a new +<PeakList1D>+ XML node sharing GC lifecycle with +document+.
            #
            # @param document [Nokogiri::XML::Document] an XML document
            # @return [Nokogiri::XML::Node] a new +<PeakList1D>+ XML node (on success), or +nil+ (on failure)
            def to_xml(document)
              node = Nokogiri::XML::Node.new('PeakList1D', document)

              node << @header.to_xml(document)

              @children.each do |child|
                node << child.to_xml(document)
              end

              node
            end
          end

          ###
          # Representation of +<PeakList1DHeader>+ XML node.
          #
          # @!attribute [rw] creator
          #   @return [String] the creator of this +<PeakList1DHeader>+ XML node
          # @!attribute [rw] date
          #   @return [DateTime] the date and time that this +<PeakList1DHeader>+ XML node was created
          # @!attribute [rw] expNo
          #   @return [Fixnum] the experiment number for this +<PeakList1DHeader>+ XML node
          # @!attribute [rw] name
          #   @return [String] the name of this +<PeakList1DHeader>+ XML node
          # @!attribute [rw] owner
          #   @return [String] the owner of this +<PeakList1DHeader>+ XML node
          # @!attribute [rw] procNo
          #   @return [Fixnum] the process number for this +<PeakList1DHeader>+ XML node
          # @!attribute [rw] source
          #   @return [String] the source for this +<PeakList1DHeader>+ XML node
          # @!attribute [rw] details
          #   @return [Bruker::TopSpin::PeakList::XML::Nodes::PeakPickDetails] the +<PeakPickDetails>+ XML node for this +<PeakList1DHeader>+ XML node
          class PeakList1DHeader < Bruker::TopSpin::PeakList::XML::Node
            class << self
              ###
              # Parse an XML document.
              #
              # @param document [Nokogiri::XML::Document] an XML document
              # @return [Bruker::TopSpin::PeakList::XML::Nodes::PeakList1DHeader, nil] representation of +<PeakList1DHeader>+ XML node (on success), or +nil+ (on failure)
              def parse(document)
                return nil if document.nil?
                return nil unless document.name == 'PeakList1DHeader'

                creator = if !(attribute = document.attribute('creator')).nil?
                  attribute.value.to_s
                else
                  nil
                end

                date = if !(attribute = document.attribute('date')).nil?
                  DateTime.strptime(attribute.value.to_s, Bruker::TopSpin::PeakList::XML::DATETIME_FORMAT)
                else
                  nil
                end

                expNo = if !(attribute = document.attribute('expNo')).nil?
                  attribute.value.to_i
                else
                  nil
                end

                name = if !(attribute = document.attribute('name')).nil?
                  attribute.value.to_s
                else
                  nil
                end

                owner = if !(attribute = document.attribute('owner')).nil?
                  attribute.value.to_s
                else
                  nil
                end

                procNo = if !(attribute = document.attribute('procNo')).nil?
                  attribute.value.to_i
                else
                  nil
                end

                source = if !(attribute = document.attribute('source')).nil?
                  attribute.value.to_s
                else
                  nil
                end

                details = document.xpath('PeakPickDetails').collect { |node|
                  Bruker::TopSpin::PeakList::XML::Nodes::PeakPickDetails.parse(node)
                }.first

                new(creator, date, expNo, name, owner, procNo, source, details)
              end
            end

            attr_accessor :creator, :date, :expNo, :name, :owner, :procNo, :source, :details

            ###
            # Default constructor.
            #
            # @param creator [String] the creator of this +<PeakList1DHeader>+ XML node
            # @param date [DateTime] the date and time that this +<PeakList1DHeader>+ XML node was created
            # @param expNo [Fixnum] the experiment number for this +<PeakList1DHeader>+ XML node
            # @param name [String] the name of this +<PeakList1DHeader>+ XML node
            # @param owner [String] the owner of this +<PeakList1DHeader>+ XML node
            # @param procNo [Fixnum] the process number for this +<PeakList1DHeader>+ XML node
            # @param source [String] the source for this +<PeakList1DHeader>+ XML node
            # @param details [Bruker::TopSpin::PeakList::XML::Nodes::PeakPickDetails] the +<PeakPickDetails>+ XML node for this +<PeakList1DHeader>+ XML node
            def initialize(creator, date, expNo, name, owner, procNo, source, details)
              super()

              @creator = creator
              @date = date
              @expNo = expNo
              @name = name
              @owner = owner
              @procNo = procNo
              @source = source

              @details = details
            end

            ###
            # Create a new +<PeakList1DHeader>+ XML node sharing GC lifecycle with +document+.
            #
            # @param document [Nokogiri::XML::Document] an XML document
            # @return [Nokogiri::XML::Node] a new +<PeakList1DHeader>+ XML node (on success), or +nil+ (on failure)
            def to_xml(document)
              node = Nokogiri::XML::Node.new('PeakList1DHeader', document)

              node.set_attribute('creator', @creator.to_s)
              node.set_attribute('date', @date.respond_to?(:strftime) ? @date.strftime(Bruker::TopSpin::PeakList::XML::DATETIME_FORMAT) : '')
              node.set_attribute('expNo', @expNo.to_s)
              node.set_attribute('name', @name.to_s)
              node.set_attribute('owner', @owner.to_s)
              node.set_attribute('procNo', @procNo.to_s)
              node.set_attribute('source', @source.to_s)

              node << @details.to_xml(document)

              return node
            end
          end

          ###
          # Representation of +<PeakPickDetails>+ XML node.
          #
          # @!attribute [rw] F1
          #   @return [Float] F1 coordinate (units: ppm)
          # @!attribute [rw] F2
          #   @return [Float] F2 coordinate (units: ppm)
          # @!attribute [rw] MI
          #   @return [Float] minimum intensity (units: cm)
          # @!attribute [rw] MAXI
          #   @return [Float] maximum intensity (units: cm)
          # @!attribute [rw] PC
          #   @return [Float] processing parameter (units: dimensionless)
          class PeakPickDetails < Bruker::TopSpin::PeakList::XML::Node
            ###
            # Regular expression for text content of +<PeakPickDetails>+ XML node.
            #
            # @return [Regexp]
            CONTENT_REGEXP = Regexp.new('^\s*F1=(.+)ppm,\s*F2=(.+)ppm,\s*MI=(.+)cm,\s*MAXI=(.+)cm,\s*PC=(.+)\s*$').freeze

            ###
            # Template for text content of +<PeakPickDetails>+ XML node.
            #
            # @return [String]
            CONTENT_FORMAT = 'F1=%fppm, F2=%fppm, MI=%fcm, MAXI=%fcm, PC=%f'.freeze

            class << self
              ###
              # Parse an XML document.
              #
              # @param document [Nokogiri::XML::Document] an XML document
              # @return [Bruker::TopSpin::PeakList::XML::Nodes::PeakPickDetails, nil] representation of +<PeakPickDetails>+ XML node (on success), or +nil+ (on failure)
              def parse(document)
                return nil if document.nil?
                return nil unless document.name == 'PeakPickDetails'

                if !(md = CONTENT_REGEXP.match(document.content.to_s.strip)).nil?
                  new(md[1].to_f, md[2].to_f, md[3].to_f, md[4].to_f, md[5].to_f)
                else
                  nil
                end
              end
            end

            attr_accessor :F1, :F2, :MI, :MAXI, :PC

            ###
            # Default constructor.
            #
            # @param _F1 [Float] F1 coordinate (units: ppm)
            # @param _F2 [Float] F2 coordinate (units: ppm)
            # @param _MI [Float] minimum intensity integral (units: cm)
            # @param _MAXI [Float] maximum intensity integral (units: cm)
            # @param _PC [Float] processing parameter (units: dimensionless)
            def initialize(_F1, _F2, _MI, _MAXI, _PC)
              super()

              @F1 = _F1
              @F2 = _F2
              @MI = _MI
              @MAXI = _MAXI
              @PC = _PC
            end

            ###
            # Create a new +<PeakPickDetails>+ XML node sharing GC lifecycle with +document+.
            #
            # @param document [Nokogiri::XML::Document] an XML document
            # @return [Nokogiri::XML::Node] a new +<PeakPickDetails>+ XML node (on success), or +nil+ (on failure)
            def to_xml(document)
              node = Nokogiri::XML::Node.new('PeakPickDetails', document)

              node.content = Kernel.sprintf(CONTENT_FORMAT, @F1, @F2, @MI, @MAXI, @PC)

              node
            end
          end

          ###
          # Representation of +<Peak1D>+ XML node.
          #
          # @!attribute [rw] F1
          #   @return [Float] F1 coordinate (units: ppm)
          # @!attribute [rw] intensity
          #   @return [Float] intesity integral (units: cm)
          # @!attribute [rw] type
          #   @return [Fixnum] type
          class Peak1D < Bruker::TopSpin::PeakList::XML::Node
            class << self
              ###
              # Parse an XML document.
              #
              # @param document [Nokogiri::XML::Document] an XML document
              # @return [Bruker::TopSpin::PeakList::XML::Nodes::Peak1D, nil] representation of +<Peak1D>+ XML node (on success), or +nil+ (on failure)
              def parse(document)
                return nil if document.nil?
                return nil unless document.name == 'Peak1D'

                _F1 = if !(attribute = document.attribute('F1')).nil?
                  attribute.value.to_f
                else
                  nil
                end

                intensity = if !(attribute = document.attribute('intensity')).nil?
                  attribute.value.to_f
                else
                  nil
                end

                type = if !(attribute = document.attribute('type')).nil?
                  attribute.value.to_i
                else
                  nil
                end

                new(_F1, intensity, type)
              end
            end

            attr_accessor :F1, :intensity, :type

            ###
            # Default constructor.
            #
            # @param _F1 [Float] F1 coordinate (units: ppm)
            # @param intensity [Float] intesity integral (units: cm)
            # @param type [Fixnum] type
            def initialize(_F1, intensity, type)
              super()

              @F1 = _F1
              @intensity = intensity
              @type = type
            end

            ###
            # Create a new +<Peak1D>+ XML node sharing GC lifecycle with +document+.
            #
            # @param document [Nokogiri::XML::Document] an XML document
            # @return [Nokogiri::XML::Node] a new +<Peak1D>+ XML node (on success), or +nil+ (on failure)
            def to_xml(document)
              node = Nokogiri::XML::Node.new('Peak1D', document)

              node.set_attribute('F1', @F1.to_s)
              node.set_attribute('intensity', @intensity.to_s)
              node.set_attribute('type', @type.to_s)

              node
            end
          end
        end
      end
    end
  end
end
