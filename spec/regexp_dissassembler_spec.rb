# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Capybara::Selector::RegexpDisassembler do
  it 'handles strings' do
    verify_strings(
      /abcdef/ => %w[abcdef],
      /abc def/ => ['abc def']
    )
  end

  it 'handles escaped characters' do
    verify_strings(
      /abc\\def/ => %w[abc\def],
      /abc\.def/ => %w[abc.def],
      /\nabc/ => ["\nabc"],
      %r{abc/} => %w[abc/],
      /ab\++cd/ => %w[ab+ cd]
    )
  end

  it 'handles wildcards' do
    verify_strings(
      /abc.*def/ => %w[abc def],
      /.*def/ => %w[def],
      /abc./ => %w[abc],
      /abc.*/ => %w[abc],
      /abc.def/ => %w[abc def],
      /abc.def.ghi/ => %w[abc def ghi]
    )
  end

  it 'handles optional characters' do
    verify_strings(
      /abc*def/ => %w[ab def],
      /abc*/ => %w[ab],
      /abc?def/ => %w[ab def],
      /abc?/ => %w[ab],
      /abc?def?/ => %w[ab de],
      /abc?def?g/ => %w[ab de g]
    )
  end

  it 'handles character classes' do
    verify_strings(
      /abc[a-z]/ => %w[abc],
      /abc[a-z]def[0-9]g/ => %w[abc def g],
      /[0-9]abc/ => %w[abc],
      /[0-9]+/ => %w[],
      /abc[0-9&&[^7]]/ => %w[abc]
    )
  end

  it 'handles posix bracket expressions' do
    verify_strings(
      /abc[[:alpha:]]/ => %w[abc],
      /[[:digit:]]abc/ => %w[abc],
      /abc[[:print:]]def/ => %w[abc def]
    )
  end

  it 'handles repitition' do
    verify_strings(
      /abc{3}/ => %w[abccc],
      /abc{3}d/ => %w[abcccd],
      /abc{0}/ => %w[ab],
      /abc{,2}/ => %w[ab],
      /abc{2,}/ => %w[abcc],
      /def{1,5}/ => %w[def],
      /abc+def/ => %w[abc def],
      /ab(cde){,4}/ => %w[ab],
      /(ab){,2}cd/ => %w[cd],
      /(abc){2,3}/ => %w[abcabc],
      /(abc){3}/ => %w[abcabcabc],
      /ab{2,3}cd/ => %w[abb cd],
      /(ab){2,3}cd/ => %w[abab cd]
    )
  end

  it 'handles non-greedy repetition' do
    verify_strings(
      /abc.*?/ => %w[abc],
      /abc+?/ => %w[abc],
      /abc*?cde/ => %w[ab cde],
      /(abc)+?def/ => %w[abc def],
      /ab(cde)*?fg/ => %w[ab fg]
    )
  end

  it 'handles alternation' do
    verify_strings(
      /abc|def/ => [],
      /ab(?:c|d)/ => %w[ab],
      /ab(c|d)ef/ => %w[ab ef]
    )
  end

  it 'handles grouping' do
    verify_strings(
      /(abc)/ => %w[abc],
      /(abc)?/ => [],
      /ab(cde)/ => %w[abcde],
      /(abc)de/ => %w[abcde],
      /ab(cde)fg/ => %w[abcdefg],
      /ab(?<name>cd)ef/ => %w[abcdef],
      /gh(?>ij)kl/ => %w[ghijkl],
      /m(n.*p)q/ => %w[mn pq],
      /(?:ab(cd)*){2,3}/ => %w[ab],
      /(ab(cd){3})?/ => [],
      /(ab(cd)+){2}/ => %w[abcd]
    )
  end

  it 'handles meta characters' do
    verify_strings(
      /abc\d/ => %w[abc],
      /abc\wdef/ => %w[abc def],
      /\habc/ => %w[abc]
    )
  end

  it 'handles character properties' do
    verify_strings(
      /ab\p{Alpha}cd/ => %w[ab cd],
      /ab\p{Blank}/ => %w[ab],
      /\p{Digit}cd/ => %w[cd]
    )
  end

  it 'handles backreferences' do
    verify_strings(
      /a(?<group>abc).\k<group>.+/ => %w[aabc]
    )
  end

  it 'handles subexpressions' do
    verify_strings(
      /\A(?<paren>a\g<paren>*b)+\z/ => %w[a b]
    )
  end

  it 'handles anchors' do
    verify_strings(
      /^abc/ => %w[abc],
      /def$/ => %w[def],
      /^abc$/ => %w[abc]
    )
  end

  def verify_strings(hsh)
    hsh.each do |regexp, expected|
      expect(Capybara::Selector::RegexpDisassembler.new(regexp).substrings).to eq expected
    end
  end
end
