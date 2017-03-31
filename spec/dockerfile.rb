require "serverspec"
require "docker"

metadata = YAML.load(File.open('metadata.yaml'))
buildargs="{
  \"FLUENTD_VERSION\":\"#{metadata['fluentd']['version']}\",
  \"FLUENTD_PROJECT\":\"#{metadata['fluentd']['project']}\",
  \"VERSION\":\"#{metadata['version']}\"
}"

name="spec_dockerfile_#{metadata['name']}:#{metadata['version']}"

describe "Dockerfile for #{metadata['name']} should" do 
  before (:all) do
    Docker.options[:read_timeout] = 100000
    Docker.options[:write_timeout] = 100000
    @image = Docker::Image.build_from_dir(
        '.',{
            't'         => name,
            'buildargs' => "#{buildargs}"
        }
    )
    set :os, family: :alpine
    set :backend, :dockerfile
    set :docker_image, @image.id
  end

  it "exist" do
    expect(@image).not_to be_nil
  end

  it "have an entrypoint defined" do
    expect(@image.json["Config"]["Entrypoint"]).to include("/fluentd/entrypoint.sh")
  end

  it "have a label Description defined" do
    expect(@image.json["ContainerConfig"]["Labels"]["Description"]).not_to be_nil
  end
  it "have a label Fluentd Version defined" do
    expect(@image.json["ContainerConfig"]["Labels"]["Fluentd_version"]).not_to be_nil
  end

  it "have a label Project defined" do
    expect(@image.json["ContainerConfig"]["Labels"]["Project"]).not_to be_nil
  end

  it "have a label Version defined" do
    expect(@image.json["ContainerConfig"]["Labels"]["Version"]).not_to be_nil
  end

  it "have a maintainer defined" do
    expect(@image.json["Author"]).not_to be_nil
  end
end
