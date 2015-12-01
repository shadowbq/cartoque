require 'spec_helper'
require 'rt_instance'

class RtInstance
  def self.dir
    Rails.root.join("spec/data/rt").to_s
  end
end

describe RtInstance do
  describe "RedmineInstance.all" do
    it "returns fake directory" do
      expect(RtInstance.dir).to include("spec/data/rt")
    end

    it "returns all rt instances" do
      instances = RtInstance.all
      expect(instances.size).to eq 2
      instance = instances.detect{|i| i.name == "rt_client_01"}
      expect(instance).to be_a_kind_of RtInstance
      expect(instance.server).to eq "rt-01"
      expect(instance.nb_users).to eq 261
      expect(instance.no_method).to eq ""
    end
  end
end
