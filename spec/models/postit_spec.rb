require 'spec_helper'

describe Postit do
  describe "#to_s" do
    it "delegates to commentable model" do
      server = Server.new(name: "server-66")
      expect(server.build_postit.to_s).to eq("server-66")
    end
  end
end
