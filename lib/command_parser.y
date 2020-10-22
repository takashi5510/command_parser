class CommandParser

rule
  line  : func '(' args ')'   { result = val }
  func  : IDENT ':' ':' IDENT { result = val.join }
  args  : arg                 { result = val }
        | args ',' arg        { result << val[2] }
        | # nil
  arg   : str
        | num
        | ary
  str   : '"' IDENT '"'       { result = val[1] }
  num   : NUM                 { result = val[0].to_i }
  ary   : '[' items ']'       { result = val[1] }
  items : item                { result = val }
        | items ',' item      { result << val[2] }
  item  : str
        | num
end

---- header
require 'strscan'

---- inner
def parse(str)
  @yydebug = true
  s = StringScanner.new(str)
  @q = []
  until s.eos?
    # TODO: スペース未対応
    # TODO: \, \" 未対応
    case
    when s.scan(/[1-9][0-9]*/)
      @q << [:NUM, s.matched]
    when s.scan(/\w+/)
      @q << [:IDENT, s.matched]
    when s.scan(/./)
      @q << [s.matched, s.matched]
    when s.scan(/$/)
      @q << [:E, s.matched]
    else
      break
    end
  end
  p @q
  do_parse
end

def next_token
  @q.shift
end

---- footer
if __FILE__ == $0
  parser = CommandParser.new
  begin
    p parser.parse(ARGV[0])
  rescue Racc::ParseError => e
    $stderr.puts e
  end
end

