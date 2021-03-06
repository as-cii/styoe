require 'styoe'

describe Styoe::Launcher do
  let(:configuration_resolver) { instance_double(Styoe::ConfigurationResolver) }
  let(:process_launcher)       { instance_double(Styoe::ProcessLauncher) }
  let(:pids)                   { [ 1, 2, 3 ] }

  subject { Styoe::Launcher.new(configuration_resolver, process_launcher) }

  it "launches configuration processes and remembers open pids" do
    allow(configuration_resolver).to receive(:processes).and_return(["app1", "app2", "app3"])
    allow(configuration_resolver).to receive(:dump_processes)
    stub_processes_launch("app1" => 1, "app2" => 2, "app3" => 3)

    subject.start

    expect(configuration_resolver).to have_received(:dump_processes).with([
      Styoe::RunningProcess.new("app1", 1),
      Styoe::RunningProcess.new("app2", 2),
      Styoe::RunningProcess.new("app3", 3)
    ])
  end

  it 'stops active processes' do
    allow(configuration_resolver).to receive(:active_processes).and_return(pids)
    allow(process_launcher).to receive(:stop)

    subject.stop

    expect_processes_stopped
  end

  private

  def stub_processes_launch(processes)
    processes.each do |process, pid|
      allow(process_launcher).to receive(:launch).with(process).and_return(pid)
    end
  end

  def expect_processes_stopped
    pids.each do |pid|
      expect(process_launcher).to have_received(:stop).with(pid)
    end
  end
end
