require 'spec_helper'

describe Cronjob do
  describe "Cronjob#parse" do
    it "parses a simple, standard cron line" do
      line = "00  05  *  *  *  root  /opt/scripts/my-own-script"
      cron = Cronjob.parse_line(line)
      expect(cron).not_to be_valid
      cron.server = FactoryGirl.create(:server)
      expect(cron).to be_valid
      expect(cron.frequency).to eq "00 05 * * *"
      expect(cron.user).to eq "root"
      expect(cron.command).to eq "/opt/scripts/my-own-script"
    end

    it "parses a cron line with the definition location in first column" do
      line = "/etc/crontab 00  05  *  *  *  root  /opt/scripts/my-own-script"
      cron = Cronjob.parse_line(line)
      expect(cron).not_to be_valid
      cron.server = FactoryGirl.create(:server)
      expect(cron).to be_valid
      expect(cron.definition_location).to eq "/etc/crontab"
      expect(cron.frequency).to eq "00 05 * * *"
      expect(cron.user).to eq "root"
      expect(cron.command).to eq "/opt/scripts/my-own-script"
    end

    it "parses a cron line with a special frequency" do
      line = "@reboot root  /opt/scripts/my-own-script"
      cron = Cronjob.parse_line(line)
      cron.server_id = FactoryGirl.create(:server).id
      cron.save!
      expect(cron.frequency).to eq "@reboot"
      expect(cron.user).to eq "root"
      expect(cron.command).to eq "/opt/scripts/my-own-script"
    end

    it "is not valid with 'strongly' invalid cron lines" do
      [ "",
        "      ",
        "less than six elements in line",
        "m h d  m  w  user  command",
        "#* * * * * user commented cron",
        "@rebootz user invalid special frequency"
      ].each do |line|
        expect(Cronjob.parse_line(line)).not_to be_valid
      end
    end

    it "is able to parse a cron file correctly" do
      server = Server.find_or_create_by(name: "server-01")
      crons = File.readlines(File.expand_path("../../data/crons/server-01.cron", __FILE__)).map do |line|
        c = Cronjob.parse_line(line)
        c.server = server
        c
      end
      expect(crons.shift).not_to be_valid
      expect(crons.size).to eq 13
      expect(crons.map(&:valid?).uniq).to eq [true]
    end
  end
end
