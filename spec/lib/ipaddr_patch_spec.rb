require 'spec_helper'

describe 'IPAddr patches' do
  describe '.valid?' do
    it 'should not be valid with non IP strings' do
      expect(IPAddr.valid?("")).to be_falsey
      expect(IPAddr.valid?("abc")).to be_falsey
      expect(IPAddr.valid?("1.2.3.4a")).to be_falsey
    end

    it 'should be valid with with IP strings' do
      expect(IPAddr.valid?("1.2.3.4")).to be_truthy
      expect(IPAddr.valid?("255.255.255.255")).to be_truthy
      expect(IPAddr.valid?("255.255.255.256")).to be_falsey
    end

    it 'should be valid with integers in a certain limit' do
      expect(IPAddr.valid?(0)).to be_truthy
      expect(IPAddr.valid?(123450)).to be_truthy
      expect(IPAddr.valid?(12345123451234512345)).to be_falsey
    end
  end

  describe '.new_from_int' do
    #def self.new_from_int(addr)
    #  unless addr.blank?
    #    new(Integer(addr), Socket::AF_INET).to_s rescue nil
    #  end
    #end
  end
end
