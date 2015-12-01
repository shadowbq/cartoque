require 'spec_helper'

describe BackupJob do
  it "is valid with just a hierarchy and a server" do
    job = BackupJob.new
    expect(job).not_to be_valid
    job.hierarchy = "/"
    job.server = FactoryGirl.create(:server)
    expect(job).to be_valid
  end
end
