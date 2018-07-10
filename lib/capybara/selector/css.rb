# frozen_string_literal: true

module Capybara
  class Selector
    class CSS
      def self.escape(str)
        value = str.dup
        out = +''
        out << value.slice!(0...1) if value =~ /^[-_]/
        out << (value[0] =~ NMSTART ? value.slice!(0...1) : escape_char(value.slice!(0...1)))
        out << value.gsub(/[^a-zA-Z0-9_-]/) { |c| escape_char c }
        out
      end

      def self.escape_char(c)
        c =~ %r{[ -/:-~]} ? "\\#{c}" : format('\\%06x', c.ord)
      end

      def self.split(css)
        Splitter.new.split(css)
      end

      S = '\u{80}-\u{D7FF}\u{E000}-\u{FFFD}\u{10000}-\u{10FFFF}'
      H = /[0-9a-fA-F]/
      UNICODE  = /\\#{H}{1,6}[ \t\r\n\f]?/
      NONASCII = /[#{S}]/
      ESCAPE   = /#{UNICODE}|\\[ -~#{S}]/
      NMSTART = /[_a-zA-Z]|#{NONASCII}|#{ESCAPE}/

      class Splitter
        def split(css)
          selectors = []
          StringIO.open(css) do |str|
            selector = ''
            while (c = str.getc)
              case c
              when '['
                selector += parse_square(str)
              when '('
                selector += parse_paren(str)
              when '"', "'"
                selector += parse_string(c, str)
              when '\\'
                selector += c + str.getc
              when ','
                selectors << selector.strip
                selector = ''
              else
                selector += c
              end
            end
            selectors << selector.strip
          end
          selectors
        end

      private

        def parse_square(strio)
          parse_block('[', ']', strio)
        end

        def parse_paren(strio)
          parse_block('(', ')', strio)
        end

        def parse_block(start, final, strio)
          block = start
          while (c = strio.getc)
            case c
            when final
              return block + c
            when '\\'
              block += c + strio.getc
            when '"', "'"
              block += parse_string(c, strio)
            else
              block += c
            end
          end
          raise ArgumentError, "Invalid CSS Selector - Block end '#{final}' not found"
        end

        def parse_string(quote, strio)
          string = quote
          while (c = strio.getc)
            string += c
            case c
            when quote
              return string
            when '\\'
              string += strio.getc
            end
          end
          raise ArgumentError, 'Invalid CSS Selector - string end not found'
        end
      end
    end
  end
end
