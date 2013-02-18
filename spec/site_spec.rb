require_relative '../lib/makefolio'

require 'fileutils'
require 'rspec-html-matchers'

describe Makefolio::Site do
  let(:site) { Makefolio::Site.new('./spec/_src') }

  describe "when created" do
    it "should have a path" do
      site.path.to_s.should == './spec/_src'
    end

    it "should have a project path" do
      site.project_path.to_s.should == './spec/_src/projects'
    end

    it "should have a template path" do
      site.template_path.to_s.should == './spec/_src/templates'
    end

    it "should have a collection of projects" do
      names = site.projects.collect { |p| p.name }
      names.should match_array([ 'one', 'two', 'three'])
    end
  end

  describe "when generating" do
    before do
      FileUtils.rm_rf('./spec/dist/')
      site.generate
    end

    describe "the index file" do
      it "should exist" do
        Pathname.new('./spec/dist/index.html').exist?.should be_true
      end

      it "should contain each project's info" do
        index = IO.read('./spec/dist/index.html')
        index.should have_tag('body') do
          with_tag 'h2', :text => 'one'
          with_tag 'h2', :text => 'two'
          with_tag 'h2', :text => 'three'
        end
      end
    end

    it "should create an html file for each project" do
      dist = Pathname.new('./spec/dist')
      files = dist.children.select { |c| c.file? }.collect { |c| c.relative_path_from(dist).to_s }
      files.should include('one.html', 'two.html', 'three.html')
    end

    after(:all) do
      # FileUtils.rm_rf('./spec/dist/')
    end
  end
end