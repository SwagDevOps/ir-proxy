# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Thin wrapper on top of rouge.
#
# @see https://github.com/rouge-ruby/rouge
class IrProxy::SyntaxHighlighter
  autoload(:Rouge, 'rouge')

  # @param [Symbol] lexer
  def initialize(lexer)
    @lexer = Rouge::Lexers.const_get(lexer.to_sym)
    @formatter = Rouge::Formatters::Terminal256.new
  end

  # @param [String] source
  def call(source, output: $stdout)
    output&.isatty ? lexer.lex(source).yield_self { |s| formatter.format(s) } : source
  end

  protected

  # @return [Rouge::Lexer]
  attr_reader :lexer

  # @return [Rouge::Formatter]
  attr_reader :formatter
end
