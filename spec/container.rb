require "serverspec"
require "yaml"
require "docker"

metadata = YAML.load(File.open('metadata.yaml'))
image = "spec/#{metadata['name']}:#{metadata['version']}"


files=[
  '/fluentd/etc/fluent.conf',
  '/fluentd/etc/conf.d/kubernetes.conf',
  '/fluentd/entrypoint.sh'
]

directories=[
  '/fluentd/log',
  '/fluentd/plugins',
  '/fluentd/etc',
  '/fluentd/plugins',
  '/fluentd/tmp',
  ''
]

gems = [
    'oj',
    'json',
    'fluentd',
    'fluent-plugin-rewrite-tag-filter',
    'fluent-plugin-kubernetes_metadata_filter',
    'fluent-plugin-azure-loganalytics',
    'fluent-plugin-forest'
]

describe "Container: #{image} should have" do
    before(:all) do
       Docker.options[:read_timeout] = 100000
       Docker.options[:write_timeout] = 100000
       @image=Docker::Image.build_from_dir('.',{ 't' => image })
       @container = Docker::Container.create(
         'Image'      => image,
         'Entrypoint' => ["sh", "-c", "tail -f /dev/null"],
         'Env'        => [
           "AZURE_WORKSPACE_ID=azure_workspace_id",
           "AZURE_SHARED_KEY=azure_storage_account_shared_key"
          ])
       @container.start

       set :os, family: :alpine
       set :backend, :docker
       set :docker_container, @container.id
    end

    after(:all) do
        @container.kill
        @container.delete(:force => true)
        @image.remove(:force => true)
    end
    
    directories.each do |name|
      it "directory: #{name}" do
        config = '/fluentd/plugins'
        expect(file(config)).to be_a_directory
      end
    end


    files.each do |name|
      it "file: #{name}" do
        expect(file(name)).to be_a_file
      end
    end

    gems.each do |gem| 
      it "gem: #{gem}" do
        expect(package(gem)).to be_installed.by('gem')
      end
    end

    it "run in dry mode without errors" do
        expect(command('/fluentd/entrypoint.sh --dry-run').exit_status).to equal(0)
    end
end
