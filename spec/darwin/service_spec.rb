require 'spec_helper'

include Serverspec::Helper::Darwin

#describe service('sshd') do
#  it { should be_enabled }
#end

#describe service('invalid-service') do
#  it { should_not be_enabled }
#end

#describe service('sshd') do
#  it { should be_enabled.with_level(3) }
#end

#describe service('invalid-service') do
#  it { should_not be_enabled.with_level(3) }
#end

describe service('sshd') do
  it { should be_running }
  its(:command) { should eq "service sshd status" }
end

describe service('invalid-daemon') do
  it { should_not be_running }
end

describe service('sshd') do
  let(:stdout) { "sshd is stopped\r\n" }
  it { should be_running }
end

describe service('sshd') do
  let(:stdout) { "sshd RUNNING\r\n" }
  it { should be_running.under('supervisor') }
end

describe service('sshd') do
  let(:stdout) { "sshd STOPPED\r\n" }
  it { should_not be_running.under('supervisor') }
end

describe service('invalid-daemon') do
  it { should_not be_running.under('supervisor') }
end

describe service('sshd') do
  let(:stdout) { "sshd running\r\n" }
  it { should be_running.under('upstart') }
end

describe service('sshd') do
  let(:stdout) { "sshd waiting\r\n" }
  it { should_not be_running.under('upstart') }
end

describe service('invalid-daemon') do
  it { should_not be_running.under('upstart') }
end

describe service('sshd') do
  it {
    expect {
      should be_running.under('not implemented')
    }.to raise_error(ArgumentError, %r/\A`be_running` matcher doesn\'t support/)
  }
end

describe service('sshd') do
  let(:stdout) { "Process 'sshd'\r\n  status running\r\n  monitoring status  monitored" }
  it { should be_monitored_by('monit') }
  its(:command) { should eq "monit status" }
end

describe service('sshd') do
  let(:stdout) { "Process 'sshd'\r\n  status  not monitored\r\n  monitoring status  not monitored" }
  it { should_not be_monitored_by('monit') }
end

describe service('invalid-daemon') do
  it { should_not be_monitored_by('monit') }
end

describe service('unicorn') do
  let(:stdout) { "unicorn: up\r\n" }
  it { should be_monitored_by('god') }
  its(:command) { should eq "god status unicorn" }
end

describe service('unicorn') do
  let(:stdout) { "unicorn: unmonitored\r\n" }
  it { should_not be_monitored_by('god') }
  its(:command) { should eq "god status unicorn" }
end

describe service('invalid-daemon') do
  it { should_not be_monitored_by('god') }
end

describe service('sshd') do
  it {
    expect {
      should be_monitored_by('not implemented')
    }.to raise_error(ArgumentError, %r/\A`be_monitored_by` matcher doesn\'t support/)
  }
end
