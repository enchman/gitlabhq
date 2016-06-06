require 'spec_helper'

describe "Builds" do
  let(:artifacts_file) { fixture_file_upload(Rails.root + 'spec/fixtures/banana_sample.gif', 'image/gif') }

  before do
    login_as(:user)
    @commit = FactoryGirl.create :ci_commit
    @build = FactoryGirl.create :ci_build, commit: @commit
    @build2 = FactoryGirl.create :ci_build
    @project = @commit.project
    @project.team << [@user, :master]
  end

  describe "GET /:project/builds" do
    context "Running scope" do
      before do
        @build.run!
        visit namespace_project_builds_path(@project.namespace, @project)
      end

      it { expect(page).to have_content 'Running' }
      it { expect(page).to have_content 'Cancel running' }
      it { expect(page).to have_content @build.short_sha }
      it { expect(page).to have_content @build.ref }
      it { expect(page).to have_content @build.name }
    end

    context "Finished scope" do
      before do
        @build.run!
        visit namespace_project_builds_path(@project.namespace, @project, scope: :finished)
      end

      it { expect(page).to have_content 'No builds to show' }
      it { expect(page).to have_content 'Cancel running' }
    end

    context "All builds" do
      before do
        @project.builds.running_or_pending.each(&:success)
        visit namespace_project_builds_path(@project.namespace, @project, scope: :all)
      end

      it { expect(page).to have_content 'All' }
      it { expect(page).to have_content @build.short_sha }
      it { expect(page).to have_content @build.ref }
      it { expect(page).to have_content @build.name }
      it { expect(page).to_not have_content 'Cancel running' }
    end
  end

  describe "POST /:project/builds/:id/cancel_all" do
    before do
      @build.run!
      visit namespace_project_builds_path(@project.namespace, @project)
      click_link "Cancel running"
    end

    it { expect(page).to have_content 'No builds to show' }
    it { expect(page).to_not have_content 'Cancel running' }
  end

  describe "GET /:project/builds/:id" do
    context "Build from project" do
      before do
        visit namespace_project_build_path(@project.namespace, @project, @build)
      end

      it { expect(page.status_code).to eq(200) }
      it { expect(page).to have_content @commit.sha[0..7] }
      it { expect(page).to have_content @commit.git_commit_message }
      it { expect(page).to have_content @commit.git_author_name }
    end

    context "Build from other project" do
      before do
        visit namespace_project_build_path(@project.namespace, @project, @build2)
      end

      it { expect(page.status_code).to eq(404) }
    end

    context "Download artifacts" do
      before do
        @build.update_attributes(artifacts_file: artifacts_file)
        visit namespace_project_build_path(@project.namespace, @project, @build)
      end

      it { expect(page).to have_content 'Download artifacts' }
    end
  end

  describe "POST /:project/builds/:id/cancel" do
    context "Build from project" do
      before do
        @build.run!
        visit namespace_project_build_path(@project.namespace, @project, @build)
        click_link "Cancel"
      end

      it { expect(page.status_code).to eq(200) }
      it { expect(page).to have_content 'canceled' }
      it { expect(page).to have_content 'Retry' }
    end

    context "Build from other project" do
      before do
        @build.run!
        visit namespace_project_build_path(@project.namespace, @project, @build)
        page.driver.post(cancel_namespace_project_build_path(@project.namespace, @project, @build2))
      end

      it { expect(page.status_code).to eq(404) }
    end
  end

  describe "POST /:project/builds/:id/retry" do
    context "Build from project" do
      before do
        @build.run!
        visit namespace_project_build_path(@project.namespace, @project, @build)
        click_link 'Cancel'
        click_link 'Retry'
      end

      it { expect(page.status_code).to eq(200) }
      it { expect(page).to have_content 'pending' }
      it { expect(page).to have_content 'Cancel' }
    end

    context "Build from other project" do
      before do
        @build.run!
        visit namespace_project_build_path(@project.namespace, @project, @build)
        click_link 'Cancel'
        page.driver.post(retry_namespace_project_build_path(@project.namespace, @project, @build2))
      end

      it { expect(page.status_code).to eq(404) }
    end
  end

  describe "GET /:project/builds/:id/download" do
    context "Build from project" do
      before do
        @build.update_attributes(artifacts_file: artifacts_file)
        visit namespace_project_build_path(@project.namespace, @project, @build)
        click_link 'Download artifacts'
      end

      it { expect(page.status_code).to eq(200) }
      it { expect(page.response_headers['Content-Type']).to eq(artifacts_file.content_type) }
    end

    context "Build from other project" do
      before do
        @build2.update_attributes(artifacts_file: artifacts_file)
        visit download_namespace_project_build_path(@project.namespace, @project, @build2)
      end

      it { expect(page.status_code).to eq(404) }
    end
  end

  describe "GET /:project/builds/:id/status" do
    context "Build from project" do
      before do
        visit status_namespace_project_build_path(@project.namespace, @project, @build)
      end

      it { expect(page.status_code).to eq(200) }
    end

    context "Build from other project" do
      before do
        visit status_namespace_project_build_path(@project.namespace, @project, @build2)
      end

      it { expect(page.status_code).to eq(404) }
    end
  end
end
