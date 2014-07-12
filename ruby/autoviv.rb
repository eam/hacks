#!/usr/bin/ruby


class AutoViv
  def initialize(type=nil)
    if type == Hash
      @internal_obj = type.new { |h,k| h[k] = AutoViv.new(Hash) }
    elsif type == Array
      @internal_obj = type.new { |a,i| a[i] = AutoViv.new(Array) }
    end
  end
  
  def[](arg)
    puts "in [#{arg}] intt: #{@internal_obj[arg]}"
  end

  def []=(idx, arg)
    @internal_obj[idx] = arg
  end
  
  def index_hash(arg)
    raise "#index_hash called on Array" if @internal_type.is_a?(Array)
    @internal_obj[arg]
  end
  def index_hash=(key, val)
    raise "#index_hash= called on Array" if @internal_type.is_a?(Array)
    @internal_obj[key] = val
  end

  def index_array(arg)
    raise "#index_array called on Array" if @internal_type.is_a?(Array)
    @internal_obj[arg]
  end
end

x = AutoViv.new(Hash)
x.index_hash(5).index_array(7)

puts x.keys
