require 'spec_helper'

describe BackupExclusion do
  it "has many servers" do
    srv = FactoryGirl.create(:server)
    exception = BackupExclusion.create(reason: "Here's why !")
    exception.server_ids = [srv.id]
    exception.save
    expect(exception.reload.server_ids).to eq([srv.id])
    expect(exception.reload.servers).to eq([srv])
  end
end
