class CommandParser

rule
  line  : func '(' args ')'   { result = val }
  func  : IDENT ':' ':' IDENT { result = val }
  args  : arg                 { result = val }
        | args ',' arg        { result << val[2] }
        | # nil
  arg   : str
        | num
        | ary
  str   : STRING
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
    case
    # TODO: 負の整数対応
    # TODO: 小数点対応
    when s.scan(/[1-9][0-9]*/)
      @q << [:NUM, s.matched]
    # TODO: 引数内のスペースと\" \, 対応をparseで実施
    # TODO: ruleで対応した方がよい？？？
    when s.scan(/"(?:[\\"]|[\\,]|[^",])+"/)
      @q << [:STRING, s.matched.gsub(/^\"|\"$/, '')]
    when s.scan(/\w+/)
      @q << [:IDENT, s.matched]
    when s.scan(/\s/)
      # 引数内のスペースがparseで対応済みのため、その他のスペースは無視
    when s.scan(/./)
      @q << [s.matched, s.matched]
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

