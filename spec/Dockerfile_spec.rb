require "docker"
require "serverspec"

ELK_VERSION = "6.3.0"
ELASTICSEARCH_VERSION = ELK_VERSION
LOGSTASH_VERSION = ELK_VERSION
KIBANA_VERSION = ELK_VERSION

describe "Dockerfile" do
  before(:all) do
    image = Docker::Image.build_from_dir('.')

    set :os, family: :debian
    set :backend, :docker
    set :docker_image, image.id
  end


  ## Check OS and version

  it "installs the right version of Ubuntu" do
    expect(os_version).to include("Ubuntu 16")
  end

  def os_version
    command("lsb_release -a").stdout
  end


  ## Check that ELK stack is installed

  describe file('/opt/elasticsearch/bin/elasticsearch') do
    it { should be_file }
  end

  describe file('/opt/logstash/bin/logstash') do
    it { should be_file }
  end

  describe file('/opt/kibana/bin/kibana') do
    it { should be_file }
  end


  ## Check ELK stack versions

  it "installs the right version of Elasticsearch" do
    expect(elasticsearch_version).to include("Version: #{ELASTICSEARCH_VERSION}")
  end

  it "installs the right version of Logstash" do
    expect(logstash_version).to include(LOGSTASH_VERSION)
  end

  it "installs the right version of Kibana" do
    expect(kibana_version).to include(KIBANA_VERSION)
  end

  def elasticsearch_version
    #command("curl -XGET 'localhost:9200/?filter_path=version.number&flat_settings=true'").stdout
    command("/opt/elasticsearch/bin/elasticsearch --version").stdout
  end

  def logstash_version
    command("/opt/logstash/bin/logstash --version").stdout
  end

  def kibana_version
    command("/opt/kibana/bin/kibana --version").stdout
  end
end
