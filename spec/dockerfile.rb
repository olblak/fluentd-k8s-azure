require "serverspec"
require "docker"

metadata = YAML.load(File.open('metadata.yaml'))
name="spec/#{metadata['name']}:#{metadata['version']}"

describe "Dockerfile for #{metadata['name']} should" do 
  before (:all) do
    Docker.options[:read_timeout] = 100000
    Docker.options[:write_timeout] = 100000

    @image=Docker::Image.build_from_dir('.',{ 't' => name })
    set :os, family: :alpine
    set :backend, :dockerfile
    set :docker_image, @image.id
  end

  after (:all) do
    @image.remove(:force => true)
  end

  it "exist" do
    expect(@image).not_to be_nil
  end

  it "have an entrypoint defined" do
    expect(@image.json["Config"]["Entrypoint"]).to include("/fluentd/entrypoint.sh")
  end

  it "have label Description defined" do
    expect(@image.json["ContainerConfig"]["Labels"]["Description"]).not_to be_nil
  end
  it "have label Fluentd Version defined" do
    expect(@image.json["ContainerConfig"]["Labels"]["Fluentd_version"]).to eq("0.14.14")
  end

  it "have label Fluentd_Project defined" do
    expect(@image.json["ContainerConfig"]["Labels"]["Fluentd_Project"]).to eq("https://github.com/fluent/fluentd")
  end

  it "have label Project defined" do
    expect(@image.json["ContainerConfig"]["Labels"]["Project"]).to eq("https://github.com/olblak/fluentd-k8s-azure")
  end

  it "have label Maintainer defined" do
    expect(@image.json["ContainerConfig"]["Labels"]["Maintainer"]).to eq("Olblak <me@olblak.com>")
  end
end
