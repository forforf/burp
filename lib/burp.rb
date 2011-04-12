class Burp < Hash
  attr_reader :left_overs
  #Converts an array of hashes into a hash
  #It takes as arguments,the array of hashes (each hash representing node data)
  #and a field in the hash (node data) to use as the key for the returned hash
  def initialize(node_list, id)
    @left_overs = []
    node_list.map do |node|
      #better error information and eliminate nil keys
      node = validate(node, id) 
      #it's left over if the primary hash key doesn't exist in the node
      add_leftovers(self, @left_overs, node) unless ( node[id] && node.keys.include?(id) )
    end
  end
  
  def validate(node, id)
    begin
      self[node[id]] = node 
    rescue TypeError  #replacing an unhelpful error with something more helpful
      raise ArgumentError, "Can't use #{id.inspect} as a valid key in #{node.inspect}. "\
        "Maybe array elements are not hashes?" 
    end
  end

  def add_leftovers(main_hash, left_overs, node)
    #remove nil hash from main_hash
    main_hash.delete(nil)
    #add data to left overs (excluding nil data)
    left_overs << node if node
  end
end
