require "serverspec"
require "yaml"
require "docker"

def get_image()
    @metadata = YAML.load(File.open('metadata.yaml'))
    return "#{@metadata['namespace']}/#{@metadata['name']}:#{@metadata['version']}"
end

describe "Test container: #{get_image()}" do
    before(:all) do
       Docker.options[:read_timeout] = 100000
       Docker.options[:write_timeout] = 100000
       @container = Docker::Container.create(
         'Image'   => get_image(),
         'Env'     => [
           "AZURE_WORKSPACE_ID=azure_workspace_id",
           "AZURE_SHARED_KEY=azure_storage_account_shared_key",
           "AZURE_ARCHIVE_STORAGE_ACCOUNT=azure_storage_account",
           "AZURE_ARCHIVE_STORAGE_ACCESS_KEY=AZURE_ARCHIVE_STORAGE_ACCESS_KEY",
           "AZURE_ARCHIVE_CONTAINER=AZURE_ARCHIVE_STORAGE_CONTAINER"
          ])
       @container.start

       set :os, family: :alpine
       set :backend, :docker
       set :docker_container, @container.id
    end

    after(:all) do
        @container.kill
        @container.delete(:force => true)
    end

    describe "Fluentd Configuration" do
        it "should have global configuration" do
            config = '/fluentd/etc/fluent.conf'
            expect(file(config)).to be_a_file
        end
        it "should have kubernetes.conf" do
            config = '/fluentd/etc/conf.d/kubernetes.conf'
            expect(file(config)).to be_a_file
        end
        it "should have log directory" do
            config = '/fluentd/log'
            expect(file(config)).to be_a_directory
        end
        it "should have plugins directory" do
            config = '/fluentd/plugins'
            expect(file(config)).to be_a_directory
        end
    end

    describe "Fluentd Plugins" do
        plugins = [
            'fluent-plugin-forest',
            'fluent-plugin-azurestorage',
            'fluent-plugin-kubernetes_metadata_filter',
            'fluent-plugin-azure-loganalytics',
            'fluent-plugin-rewrite-tag-filter'
        ]
        plugins.each do |plugin|
            it "#{plugin} should be installed" do
                expect(package("#{plugin}")).to be_installed.by('gem')
            end
        end
    end 

    describe "Package fluentd" do
        it "should be installed by gem" do
            expect(package("fluentd")).to be_installed.by('gem')
        end
    end
end
