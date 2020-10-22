class CommandParser

rule
  # TODO: char以外のスペースを破棄したい（出現パターンの洗い出し）
  #       num前後、funcの先頭、スペース連続
  # TODO: charでは、ダブルクォーテーション/カンマ以外の記号も許可
  line  : func '(' args ')'   { result = val }
  func  : IDENT ':' ':' IDENT { result = val }
  args  : arg                 { result = val }
        | args ',' arg        { result << val[2] }
        | # nil
  arg   : str
        | num
        | ary
        | ' '                 { result = nil }
  str   : '"' chars '"'       { result = val[1] }
        | '"' num '"'         { result = val[1].to_s }
  chars : char                { result = val[0] }
        | chars char          { result += val[1] }
  char  : IDENT
        | '\\' '"'            { result = val[1] }
        | '\\' ','            { result = val[1] }
        | ' '
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
  #@yydebug = true
  s = StringScanner.new(str)
  @q = []
  until s.eos?
    case
    # TODO: 負の整数対応
    # TODO: 小数点対応
    when s.scan(/[1-9][0-9]*/)
      @q << [:NUM, s.matched]
    when s.scan(/\w+/)
      @q << [:IDENT, s.matched]
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

