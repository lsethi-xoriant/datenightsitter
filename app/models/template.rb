class Template
  attr_reader :key_vals, :template
  
  def initialize
    @key_vals = {}
    @template = nil
  end
  
  def template_filepath=(filepath)
    @filepath = filepath
    raise "Not a valid file_path" unless File.readable?(filepath)
    File.open(filepath) do |f|
      @template = f.read
    end
  end
  
  def add_key_val(key, value)
    temp_hash = Hash[key,value]
    @key_vals.merge!(flatten_hash(temp_hash))
  end
  
  #generates
  def process()
    raise "key values not set." if @key_vals.empty?
    raise "template file net set." if @template.nil?
    outStr = template.clone()
    key_vals.each { |key, value|
      outStr.gsub!( /{{#{key}}}/, value.to_s )
    }
    outStr
    
  end
  
  def to_s()
    process()
  end

  
  private
  
  def flatten_hash(hash, prefix="")
    output = {}
    hash.each {|key, value|
      if hash[key].is_a?(Hash)
        output.merge!(flatten_hash(hash[key], prefix=[prefix,key,"."].join))
      else
        output.merge!(Hash[([prefix,key].join),value])
      end
    }
    output
  end

end