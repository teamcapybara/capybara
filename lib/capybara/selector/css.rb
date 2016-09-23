module Capybara
  class Selector
    class CSS
      def self.escape(str)
        out = String.new("")
        value = str.dup
        out << value.slice!(0...1) if value =~ /^[-_]/
        out << if value[0] =~ NMSTART
          value.slice!(0...1)
        else
          escape_char(value.slice!(0...1))
        end
        out << value.gsub(/[^a-zA-Z0-9_-]/) {|c| escape_char c}
        out
      end

      def self.escape_char(c)
        return "\\%06x" % c.ord() unless c =~ %r{[ -/:-~]}
        "\\#{c}"
      end

      S = '\u{80}-\u{D7FF}\u{E000}-\u{FFFD}\u{10000}-\u{10FFFF}'
      H = /[0-9a-fA-F]/
      UNICODE  = /\\#{H}{1,6}[ \t\r\n\f]?/
      NONASCII = /[#{S}]/
      ESCAPE   = /#{UNICODE}|\\[ -~#{S}]/
      NMSTART  = /[_a-zA-Z]|#{NONASCII}|#{ESCAPE}/
    end
  end
end