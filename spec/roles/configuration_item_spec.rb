require 'spec_helper'

#fake models without correct prerequisites
class NotAMongoidClass1; def self.default_scope; end; end
class NotAMongoidClass2; def self.has_and_belongs_to_many; end; end

#fake model with correct prerequisites
class CIModel
  include Mongoid::Document
  include ConfigurationItem
end

RSpec.describe ConfigurationItem do
  describe 'missing pre-requisite' do
    it 'raises if the class does not respond to has_and_belongs_to_many' do
      expect {
        NotAMongoidClass1.send(:include, ConfigurationItem)
      }.to raise_error ConfigurationItem::MissingPrerequisite, /has_and_belongs/
    end

    it 'raises if the class does not respond to has_many' do
      expect do
        NotAMongoidClass2.send(:include, ConfigurationItem)
      end.to raise_error ConfigurationItem::MissingPrerequisite, /default_scope/
    end
  end

  describe 'scopes model to datacenter' do
    #
    # All tests below are run with the "Server" model, which means the behaviour
    # is not completely tested at a unit level application-wide. This would mean
    # a lot more unit tests with no real added value. If somebody has an idea
    # about how to test that more generally...
    #
    before do
      @bob         = FactoryGirl.create(:bob)
      @datacenter1 = FactoryGirl.create(:datacenter)
      @datacenter2 = FactoryGirl.create(:datacenter, name: "Phoenix")
      @server1     = FactoryGirl.create(:server, name: "server1")
      @server2     = FactoryGirl.create(:server, name: "server2")
      @server1.datacenters = [@datacenter1]
      @server1.save
      @server2.datacenters = [@datacenter2]
      @server2.save
    end

    after do
      User.current = nil
    end

    it 'sees everything if there is no User.current' do
      Server.all.to_a.should =~ [@server1, @server2]
    end

    it 'does not see anything if no visible_datacenters configured at user level' do
      User.current = @bob
      Server.all.to_a.should =~ []
    end

    it 'only sees servers in visible datacenters' do
      @bob.visible_datacenters = [@datacenter1]
      @bob.save
      User.current = @bob
      Server.all.to_a.should =~ [@server1]
    end

    it 'also scopes things for find method' do
      @bob.visible_datacenters = [@datacenter1]
      @bob.save
      User.current = @bob
      expect { Server.find(@server2.id) }.to raise_error Mongoid::Errors::DocumentNotFound
    end

    it 'sees servers in one datacenter if user has many datacenters' do
      @bob.visible_datacenters = [@datacenter1, FactoryGirl.create(:datacenter, name: "Paris")]
      @bob.save
      User.current = @bob
      Server.all.to_a.should =~ [@server1]
    end

    it 'always finds servers that have no datacenter information if user is present' do
      @server3 = FactoryGirl.create(:server, name: "server3") #datacenter_ids = [] by default
      @server4 = FactoryGirl.create(:server, name: "server4")
      @server4.unset(:datacenter_ids)
      User.current = @bob
      Server.all.to_a.should =~ [@server3, @server4]
      @bob.visible_datacenters = [@datacenter1]
      @bob.save
      Server.all.to_a.should =~ [@server1, @server3, @server4]
    end

  end

  describe 'automatic datacenter_ids' do
    before do
      Server.where(name: "pouik").destroy_all
    end

    after do
      #force cleanup so it doesn't pollute other tests
      User.current = nil
    end

    it 'does not fill datacenter_ids when blank but no User.current' do
      User.current = nil
      s = Server.create!(name: "pouik")
      s.reload.datacenters.should == []
    end

    it 'fills datacenter_ids when blank and User.current has any' do
      datacenter = FactoryGirl.create(:datacenter)
      bob = FactoryGirl.create(:bob, preferred_datacenter: datacenter)
      User.current = bob
      s = Server.create!(name: "pouik")
      s.reload.datacenters.should == [datacenter]
    end

    it 'does not replace datacenter_ids when not blank' do
      datacenter1 = FactoryGirl.create(:datacenter)
      datacenter2 = FactoryGirl.create(:datacenter, name: "Vegas")
      bob = FactoryGirl.create(:bob, preferred_datacenter: datacenter1)
      User.current = bob
      s = Server.create!(name: "pouik", datacenters: [datacenter2])
      s.reload.datacenters.should == [datacenter2]
    end

    it 'does not fill datacenter_ids for existing objects' do
      datacenter = FactoryGirl.create(:datacenter)
      bob = FactoryGirl.create(:bob, preferred_datacenter: datacenter)
      User.current = nil
      s = Server.create!(name: "pouik")
      s.reload.datacenters.should == []
      User.current = bob
      s.update_attribute(:name, "pouik2")
      s.reload.datacenters.should == []
    end
  end
end
