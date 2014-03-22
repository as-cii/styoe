require 'fire/configuration_resolver'

describe Fire::ConfigurationResolver do

  it 'resolves and parses a configuration file' do
    File.stub(:exist?).and_return(true)
    File.stub(:read).and_return(sample_configuration)

    expect(subject.processes).to eq(['hello', 'world'])
  end

  it 'searches configuration recursively in parent directories' do
    File.stub(:exist?).and_return(false, false, true)
    File.stub(:read).with("../../#{Fire::DOT_FILE}").and_return(sample_configuration)

    expect(subject.processes).to eq(['hello', 'world'])
  end

  it 'stops searching configuration when root is reached' do
    subject = described_class.new(stop_at: '/')
    File.stub(:dirname).and_return('/')

    expect { subject.processes }.to raise_error(Fire::ConfigurationNotFound)
  end

  it 'searches active processes' do
    File.stub(:exist?).and_return(true)
    File.stub(:read).and_return(sample_pids)

    expect(subject.active_processes).to eq([ 1, 2 ])
  end

  it 'searches active processes recursively' do
    File.stub(:exist?).and_return(false, false, true)
    File.stub(:read).with("../../#{Fire::PID_FILE}").and_return(sample_pids)

    expect(subject.active_processes).to eq([ 1, 2 ])
  end

  it 'stops searching active processes when root is reached' do
    subject = described_class.new(stop_at: '/')
    File.stub(:dirname).and_return('/')

    expect { subject.active_processes }.to raise_error(Fire::ConfigurationNotFound)
  end

  def sample_configuration
    <<-config
    application1: hello
    application2: world
    config
  end

  def sample_pids
    <<-pids
    application1: 1
    application2: 2
    pids
  end
end
