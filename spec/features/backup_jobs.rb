require 'spec_helper'

describe "BackupJobs" do
  let(:user) { FactoryGirl.create(:user) }
  before { login_as user }
  let!(:server) { Server.create!(name: "srv-01") }
  let!(:job) { BackupJob.create!(hierarchy: "/", server_id: server.id) }

  describe "GET /backup_jobs" do
    it "gets all jobs" do
      visit backup_jobs_path
      expect(page.status_code).to be 200
      expect(page).to have_content "srv-01"
      expect(page).to have_content "Manage exceptions"
    end
  end
end
