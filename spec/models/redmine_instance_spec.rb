require 'spec_helper'
require 'redmine_instance'

class RedmineInstance
  def self.dir
    Rails.root.join("spec/data/redmine").to_s
  end
end

describe RedmineInstance do
  describe "RedmineInstance.all" do
    it "returns fake directory" do
      expect(RedmineInstance.dir).to include("spec/data/redmine")
    end

    it "returns content of files" do
      files = RedmineInstance.files
      assert_equal 1, files.size
      assert files.first.is_a?(String)
    end

    it "returns all redmine instances" do
      instances = RedmineInstance.all
      assert_equal 3, instances.size
      instance = instances.detect{|i| i.name == "redmine-01"}
      assert instance.is_a?(RedmineInstance)
      assert_equal "server-01", instance.server
      assert_equal "1.2.0.stable", instance.version
      assert_equal 91247869, instance.size
      assert instance.plugins.is_a?(Array)
    end
  end
end
