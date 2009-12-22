require 'digest/sha1'

module Diffaroo
  class Signature
    SEP = "\0"

    def initialize(node=nil)
      @hashes  = {} # node => hash
      @nodes   = {} # hash => [node, ...]
      @weights = {} # node => weight
      @size    = 0
      @node    = node
      node_hash(node) if node
    end

    def node(hash=nil)
      hash ? @nodes[hash] : @node
    end

    def hash(node=nil)
      @hashes[node ? node : @node]
    end

    def weight(node=nil)
      @weights[node ? node : @node]
    end

    def size
      @size
    end

    def node_hash(node)
      return @hashes[node] if @hashes.key?(node)
      raise ArgumentError, "node_hash expects a Node, but received #{node.inspect}" unless node.is_a?(Nokogiri::XML::Node)

      calculated_hash = \
        if node.text?
          hashify node.content
        elsif node.element?
          children_hash = hashify(node.children       .collect { |child| node_hash(child) })
          attr_hash     = hashify(node.attributes.sort.collect { |k,v|   [k, v.value]     }.flatten)
          hashify(node.name, attr_hash, children_hash)
        else
          raise ArgumentError, "node_hash expects a text node or element, but received #{node.type}"
        end

      @size += 1
      node_weight(node)

      (@nodes[calculated_hash] ||= []) << node
      @hashes[node]                    =  calculated_hash
    end

    def node_weight(node)
      return @weights[node] if @weights.key?(node)
      raise ArgumentError, "node_weight expects a Node, but received #{node.inspect}" unless node.is_a?(Nokogiri::XML::Node)

      calculated_weight = \
        if node.text?
          1 + Math.log(node.content.length)
        elsif node.element?
          node.children.inject(1) { |sum, child| sum += node_weight(child) }
        else
          raise ArgumentError, "node_weight expects a text node or element, but received #{node.type}"
        end

      @weights[node] = calculated_weight
    end

    private

    def hashify(*args)
      if args.length == 1
        if args.first.is_a?(Array)
          Digest::SHA1.hexdigest args.first.join(SEP)
        else
          Digest::SHA1.hexdigest args.first
        end
      else
        Digest::SHA1.hexdigest args.join(SEP)
      end
    end
  end
end
