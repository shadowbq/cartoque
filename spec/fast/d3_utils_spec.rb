require 'fast_helper'
#require 'spec_helper'
require 'd3_utils'

describe D3Utils do
  it "raises an exception if instantiated" do
    expect { D3Utils.new }.to raise_error(RuntimeError)
  end

  describe ".hash_to_d3format" do
    it "transforms a simple hash" do
      source = { "a" => 2 }
      expected = [ { "name" => "a", "size" => 2 } ]
      expect(D3Utils.hash_to_d3format(source)).to eq expected
    end

    it "transforms nested hashes to children" do
      source = { "a" => { "b" => { "c" => 1, "d" => 2 } } }
      expected = [ { "name" => "a", "children" => [
                    { "name" => "b", "children" => [
                      { "name" => "c", "size" => 1 },
                      { "name" => "d", "size" => 2 }
                    ] }
                 ] } ]
      expect(D3Utils.hash_to_d3format(source)).to eq expected
    end

    it "prunes parts that are already parsed" do
      source = { "a" => { "name" => "b", "children" => [] } }
      expected = [ { "name" => "a", "children" => [ { "name" => "b", "children" => [] } ] } ]
      expect(D3Utils.hash_to_d3format(source)).to eq expected
    end
  end
end
