#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.6.0
# from Racc grammar file "".
#

require 'racc/parser.rb'

require_relative 'lexer'

class Edir::Interchange
  def initialize(header:, footer:, func_groups:)
    @header = header
    @footer = footer
    @func_groups = func_groups
  end

  def segments
    x = [@header] + @func_groups.map(&:segments).flatten + [@footer]
    pp x
  end

  def elements
    segments.map(&:elements)
  end
end

class Edir::FunctionalGroup
  def initialize(header:, footer:, transac_sets:)
    @header = header
    @footer = footer
    @transac_sets = transac_sets
  end

  def segments
    [@header] + @transac_sets.map(&:segments) + [@footer]
  end

  def elements
    segments.map(&:elements)
  end
end

class Edir::TransactionSet
  def initialize(header:, footer:, segments:)
    @header = header
    @footer = footer
    @segments = segments
  end

  def segments
    [@header] + @segments + [@footer]
  end

  def elements
    segments.map(&:elements)
  end
end

class Edir::Segment
  attr_reader :elements
  attr_reader :name
  attr_reader :raw_data

  def initialize(data)
    @raw_data = data

    @name = data.first
    @elements = []
    position = 0
    @raw_data[1..].each do |element|
      if element =~ /[*|]/
        position += 1
      else
        @elements.push([element, position])
      end
    end
  end
end

module Edir
  class Parser < Racc::Parser

module_eval(<<'...end parser.y/module_eval...', 'parser.y', 93)
def initialize(debug: false)
  @yydebug = debug
end

def parse(str)
  @q = Edir::Lexer.new.lex_str(str)
  data = do_parse
  # Implicit segment vs document mode
  if data.length > 1
    convert_document(data)
  else
    data
  end
end

def next_token
  @q.shift
end

# For each transaction set start/end, create a unique transaction set object with
# the corrsponding segments.
# For each functional group start/end, create a unique functional group object with
# the corresponding transaction sets.
# For each interchange start/end, create a unique interchange object with the corresponding
# functional groups.
def convert_document(segments)
  interchanges = partition_by_seg_types(segments: segments, seg_start: "ISA", seg_end: "IEA")
  interchanges.map do |inter|
    converted_func_groups = []
    func_groups = partition_by_seg_types(segments: inter[1..-2], seg_start: "GS", seg_end: "GE")
    func_groups.each do |func_group|
      converted_transac_sets = []
      transac_sets = partition_by_seg_types(segments: func_group[1..-2], seg_start: "ST", seg_end: "SE")
      transac_sets.each do |transac_set|
        ts = Edir::TransactionSet.new(
          header: transac_set.first,
          footer: transac_set.last,
          segments: transac_set[1..-2]
        )
        converted_transac_sets << ts
      end
      fg = Edir::FunctionalGroup.new(
        header: func_group.first,
        footer: func_group.last,
        transac_sets: converted_transac_sets
      )
      converted_func_groups << fg
    end
    inter = Edir::Interchange.new(
      header: inter.first,
      footer: inter.last,
      func_groups: converted_func_groups
    )
    inter
  end
end

def partition_by_seg_types(segments:, seg_start:, seg_end:)
  partitions = []
  while segments.length > 0 do
    part_start = segments.find_index do |segment|
      segment.name == seg_start
    end
    part_end = segments.find_index do |segment|
      segment.name == seg_end
    end
    partitions << segments[part_start..part_end]
    segments = segments[part_end+1..]
  end

  partitions
end
...end parser.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
     7,     8,     9,     8,     9,     8,     9,     3,     4,     3,
    10,    11 ]

racc_action_check = [
     3,     3,     3,     8,     8,     9,     9,     0,     1,     2,
     4,     6 ]

racc_action_pointer = [
     5,     8,     7,    -3,    10,   nil,     8,   nil,    -1,     1,
   nil,   nil,   nil,   nil ]

racc_action_default = [
    -8,    -8,    -2,    -8,    -8,    -1,    -8,    -4,    -8,    -7,
    14,    -3,    -5,    -6 ]

racc_goto_table = [
     6,     1,   nil,     5,   nil,    12,    13 ]

racc_goto_check = [
     3,     1,   nil,     1,   nil,     3,     3 ]

racc_goto_pointer = [
   nil,     1,   nil,    -3 ]

racc_goto_default = [
   nil,   nil,     2,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  2, 7, :_reduce_1,
  1, 7, :_reduce_2,
  3, 8, :_reduce_3,
  2, 8, :_reduce_4,
  2, 9, :_reduce_5,
  2, 9, :_reduce_6,
  1, 9, :_reduce_7 ]

racc_reduce_n = 8

racc_shift_n = 14

racc_token_table = {
  false => 0,
  :error => 1,
  :SEGSTART => 2,
  :SEGEND => 3,
  :ELEMSEP => 4,
  :ELEM => 5 }

racc_nt_base = 6

racc_use_result_var = true

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "SEGSTART",
  "SEGEND",
  "ELEMSEP",
  "ELEM",
  "$start",
  "segments",
  "segment",
  "elems" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

module_eval(<<'.,.,', 'parser.y', 9)
  def _reduce_1(val, _values, result)
     result = [val[0]] + val[1]
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 10)
  def _reduce_2(val, _values, result)
     result = val
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 11)
  def _reduce_3(val, _values, result)
     result = Edir::Segment.new([val[0]] + val[1])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 12)
  def _reduce_4(val, _values, result)
     result = Edir::Segment.new([val[0]])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 13)
  def _reduce_5(val, _values, result)
     result = [val[0]] + val[1]
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 14)
  def _reduce_6(val, _values, result)
     result = [val[0]] + val[1]
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 15)
  def _reduce_7(val, _values, result)
     result = val
    result
  end
.,.,

def _reduce_none(val, _values, result)
  val[0]
end

  end   # class Parser
end   # module Edir
