require 'yaml'
require 'uri'
require 'net/http'
require 'json'

@metadata = YAML.load(File.open('metadata.yaml'))
@image = "#{@metadata['namespace']}/#{@metadata['name']}:#{@metadata['version']}"

# Return true if namespace/image:tag exist
def exist?(image,digest="latest")
    # Get token
    uri = URI("https://auth.docker.io/token?service=registry.docker.io&scope=repository:#{image}:pull")
    req = JSON::parse(Net::HTTP.get_response(uri).body)
    token = req['token']

    # Get image:tag information 
    uri = URI("https://registry-1.docker.io/v2/#{image}/manifests/#{digest}")
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{token}"

    res = Net::HTTP.start(uri.hostname, uri.port,:use_ssl => uri.scheme == 'https') do |http|
        http.request(req)
    end
    return res.code == '200'
end

# Define tasks
#
desc "Build Docker Image #{@image}"
task :build do
    sh "docker build -t #{@image} ."
end

desc "Run Docker Image #{@image} with shell"
task :shell => [:build] do
	sh "docker run --rm \
		-e AZURE_WORKSPACE_ID=fake_azure_workspace_id \
		-e AZURE_SHARED_KEY=fake_azure_shared_key \
		--entrypoint /bin/sh \
		-i -t \
	    #{@image}"	
end

desc "Run Docker Image #{@image}"
task :run => [:build] do 
	sh "docker run --rm \
		-e AZURE_WORKSPACE_ID=dont_insert_cred_here \
		-e AZURE_SHARED_KEY=dont_insert_cred_here\
		#{@image}"
end

desc "Publish #{@image} to DockerHub"
task :publish do
    repository = "#{@metadata['namespace']}/#{@metadata['name']}"
    tag = "#{@metadata['version']}"
    if !exist?(repository,tag)
        sh "docker push #{@image}"
    else
        print "\n\tImage: #{@image} already published\n"
        print "\tDon't forget to update version in metadata.yaml\n\n"
    end
end

desc "Remove docker #{@image}"
task :clean do
    images = `docker images --format '{{.ID}} {{.Repository}}:{{.Tag}}'`
    images.each_line do |line|
        id, name = line.split
        if name.include? @image or name.include? '<none>:<none>'
            sh "docker rmi #{id}"
        end
    end
end

namespace :test do
    desc "Run Dockerfile tests for #{@image}"
    task :dockerfile do
        sh "rspec spec/dockerfile.rb -f d -b"
    end

    desc "Run Container tests for #{@image}"
    task :container do
        sh "rspec spec/container.rb -f d -b"
    end

    task :all => ['dockerfile','containers']
end

desc "Install gem dependencies for tests"
task :init do
    sh "bundle install"
end

desc "Run all spec files"
task :test => ["test:dockerfile","test:container"]
