class Burp < Hash
  attr_reader :left_overs
  #Converts a list of data (i.e. an array) into a ruby hash structure
  #
  #It takes as arguments,the array of hashes (each hash representing node data)
  #and a field in the hash (node data) to use as the key for the returned hash
  def initialize(node_list, id_key, data_filter = nil)
    @left_overs = []
    node_list.map do |raw_node|
      node_id = find_id(raw_node, id_key)
      if node_ok?(raw_node, node_id)
        node_burp(raw_node, node_id, data_filter)  #adds to self (i.e. this hash)
      else
        @left_overs << raw_node
      end
    end
  end

  def node_ok?(raw_node, node_id)
    resp = true
    resp = false if self.has_key?(node_id)
    resp = false if raw_node && node_id.nil?
    resp
  end
  
  def node_burp(raw_node, node_id, data_filter)
    node_data = find_data(raw_node, data_filter)
    self[node_id] = node_data
  end


  def find_id(node, id_key)
    if id_key.is_a? Proc
      id_key.call(node)
    else
      validate(node, id_key)
    end
  end
  
  def find_data(node, data_filter)
    return node unless data_filter
    if data_filter.is_a? Proc
      node_data = data_filter.call(node)
    else
      #Done this way to allow any object that supports [], []= and has_key? methods
      #I'm intentionally avoiding Hash#select/reject for this (selfish) reason
      data_filter = [data_filter].flatten
      new_data = {}
      data_filter.each do |key|
        if x.has_key?(key)
          new_data[key] = validate(node, key)
        end
      end
      new_data
    end
  end

  def validate(node, id)
    begin
      node[id]
    rescue TypeError  #replacing an unhelpful error with something more helpful
      raise ArgumentError, "Can't use #{id.inspect} as a valid key in #{node.inspect}. "\
        "Maybe you're trying a hash method on something other than a hash?"
    end
  end
end
