require_relative '../lib/makefolio'

require 'fileutils'
require 'rspec-html-matchers'

describe Makefolio::Project do
  let(:site) { Makefolio::Site.new './spec/_src/' }
  let(:project) { Makefolio::Project.new('one', site) }

  describe "with front matter" do
    it "should have a front_matter property with a hash of the data" do
      project.front_matter.should == { 'title' => 'Project One' }
    end

    it "should have a desc property with the contents of <name>.md converted to HTML" do
      project = Makefolio::Project.new('one', site)
      project.desc.should have_tag 'p', :text => 'Test paragraph'
      project.desc.should have_tag 'li', :text => 'where'
    end

    it "should return front matter data and description in tpl_data" do
      project.tpl_data.keys.should include('title', 'desc')
      project.tpl_data['title'].should == 'Project One'
      project.tpl_data['desc'].should match(/^<p>Test paragraph/)
    end
  end

  describe "without front matter" do
    let(:project) { Makefolio::Project.new('three', site) }

    it "should have a front_matter property set to an empty hash" do
      project.front_matter.should == {}
    end

    it "should have a desc property with the contents of <name>.md converted to HTML" do
      project = Makefolio::Project.new('three', site)
      project.desc.should have_tag 'p', :text => 'Test paragraph'
      project.desc.should have_tag 'li', :text => 'A moment after all four'
    end

    it "should return description and default title in tpl_data" do
      project.tpl_data.keys.should include('title', 'desc')
      project.tpl_data['title'].should == 'three'
      project.tpl_data['desc'].should match(/^<p>Test paragraph/)
    end
  end

  describe "when created" do
    it "should have a correctly set path" do
      project.path.to_s.should == './spec/_src/projects/one'
    end

    it "should have an images property containing its associated images" do
      project.images.should == [{"filename"=>"one-1.jpg", "alt"=>"Sleeping Abe", "path"=>"img/one/one-1.jpg", "filename_large"=>"one-1-lg.jpg", "path_large"=>"img/one/one-1-lg.jpg"}, {"filename"=>"one-2.jpg", "alt"=>"More sleeping Abe", "path"=>"img/one/one-2.jpg", "filename_large"=>"one-2-lg.jpg", "path_large"=>"img/one/one-2-lg.jpg"}]
    end

    describe "with a missing content file" do
      before do
        Pathname.new('./spec/_src/projects/one/one.md').rename('./spec/_src/projects/one/wrong.md')
        project = Makefolio::Project.new('one', site)
      end

      it "should set the description and front matter correctly" do
        project.desc.strip.should == ''
        project.front_matter.should == {}
      end

      after do
        Pathname.new('./spec/_src/projects/one/wrong.md').rename('./spec/_src/projects/one/one.md')
      end
    end
  end

   describe "when creating image metadata files" do
    it "should create an initial yaml file for each project without one" do
      project2 = Makefolio::Project.new('two', site)
      project2.create_image_metadata

      data = YAML.load(IO.read('./spec/_src/projects/two/images.yml'))

      # large versions of images (with -lg suffix) should be excluded
      data.should == [{"filename"=>"two-1.jpg", "alt"=>nil}, {"filename"=>"two-2.jpg", "alt"=>nil}, {"filename"=>"two-3.jpg", "alt"=>nil}]
    end

    it "should not do anything if the file already exists" do
      project.create_image_metadata

      data = YAML.load(IO.read('./spec/_src/projects/one/images.yml'))
      data[0]['alt'].should == 'Sleeping Abe'
    end

    after(:all) do
      images_two = Pathname.new('./spec/_src/projects/two/images.yml')
      if images_two.exist?
        FileUtils.rm(images_two)
      end
    end
  end

  describe "generated html file" do
    before do
      FileUtils.rm_rf './spec/dist/'
      site.generate
    end

    let(:project) { project = IO.read './spec/dist/one.html' }

    it "should use the layout" do
      project.should have_tag 'head'
    end

    it "should contain the project description" do
      project.should have_tag 'p', :text => 'Test paragraph'
    end

    it "should contain the project images" do
      project.should have_tag 'img', :count => 2
    end

    after(:all) do
      FileUtils.rm_rf './spec/dist/'
    end
  end
end
