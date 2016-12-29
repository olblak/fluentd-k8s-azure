require "serverspec"
require "docker"

describe "Test Dockerfile" do 
    before (:all) do
        Docker.options[:read_timeout] = 100000
        Docker.options[:write_timeout] = 100000
        @image = Docker::Image.build_from_dir('.')
        set :os, family: :alpine
        set :backend, :dockerfile
        set :docker_image, @image.id
    end
    it "should exist" do
        expect(@image).not_to be_nil
    end
    it "should use entrypoint" do
        expect(@image.json["Config"]["Entrypoint"]).to include("/fluentd/entrypoint.sh")
    end
    it "should have a description" do
        expect(@image.json["ContainerConfig"]["Labels"]["Description"]).not_to be_nil
    end
    it "should have a maintainer" do
        expect(@image.json["Author"]).not_to be_nil
    end
end
