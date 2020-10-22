class CommandParser

rule
end

---- header
require 'strscan'

---- inner
def parse(str)
  
end

def next_token
  @q.shift
end

---- footer
if __FILE__ == $0
  parser = CommandParser.new
  begin
    p @arser.parse(ARGV[0])
  rescue Racc::ParseError = e
    $stderr.puts e
  end
end

