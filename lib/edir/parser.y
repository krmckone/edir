class Edir::Parser
  token SEGSTART SEGEND ELEMSEP ELEM
  # local variables that racc provides in the environment of action:
  # * val is the right hand side
  # * result is the left hand side
  # The plural definitions return an array while the singular ones
  # return a single element. In order to build a sensibly flat representation of the
  # document, we concatenate the single elements with the ones that return an array
  rule
    segments : segment segments { result = [val[0]] + val[1] }
             | segment { result = val }
    segment  : SEGSTART elems SEGEND { result = Edir::Segment.new([val[0]] + val[1]) }
             | SEGSTART SEGEND { result = Edir::Segment.new([val[0]]) }
    elems    : ELEMSEP elems { result = [val[0]] + val[1] }
             | ELEM elems { result = [val[0]] + val[1] }
             | ELEM { result = val }
end

---- header
require_relative 'lexer'

class Edir::Interchange
  attr_reader :func_groups
  def initialize(header:, footer:, func_groups:)
    @header = header
    @footer = footer
    @func_groups = func_groups
  end

  def segments
    [@header] + @func_groups.map(&:segments).flatten + [@footer]
  end

  def elements
    segments.map(&:elements)
  end
end

class Edir::FunctionalGroup
  attr_reader :transac_sets

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

---- inner
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
    convert_interchange(inter) 
  end
end

def convert_interchange(inter)
  func_groups = partition_by_seg_types(segments: inter[1..-2], seg_start: "GS", seg_end: "GE")
  converted_func_groups = func_groups.map do |func_group|
    convert_functional_group(func_group) 
  end

  Edir::Interchange.new(
    header: inter.first,
    footer: inter.last,
    func_groups: converted_func_groups
  )
end

def convert_functional_group(func_group)
  transac_sets = partition_by_seg_types(segments: func_group[1..-2], seg_start: "ST", seg_end: "SE")
  converted_transac_sets = transac_sets.map do |transac_set|
    convert_transaction_set(transac_set)    
  end

  Edir::FunctionalGroup.new(
    header: func_group.first,
    footer: func_group.last,
    transac_sets: converted_transac_sets
  )
end

def convert_transaction_set(transac_set)
  Edir::TransactionSet.new(
    header: transac_set.first,
    footer: transac_set.last,
    segments: transac_set[1..-2]
  )
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
