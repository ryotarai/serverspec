require 'serverspec'
require 'pathname'
require 'rspec/mocks/standalone'

PROJECT_ROOT = (Pathname.new(File.dirname(__FILE__)) + '..').expand_path

Dir[PROJECT_ROOT.join("spec/support/**/*.rb")].each { |file| require(file) }


if vagrant_host = ENV["SERVERSPEC_VAGRANT"]
  require 'net/ssh'

  include Serverspec::Helper::Ssh
  include Serverspec::Helper::DetectOS

  RSpec.configure do |c|
    c.before :all do
      block = self.class.metadata[:example_group_block]
      if RUBY_VERSION.start_with?('1.8')
        file = block.to_s.match(/.*@(.*):[0-9]+>/)[1]
      else
        file = block.source_location.first
      end
      if c.host != vagrant_host
        c.ssh.close if c.ssh
        c.host  = vagrant_host
        user = nil
        options = {}

        config = `vagrant ssh-config --host #{c.host}`
        # TODO: abort when run specs before `vagrant up`
        if config != ''
          config.each_line do |line|
            if match = /HostName (.*)/.match(line)
              c.host = match[1]
            elsif  match = /User (.*)/.match(line)
              user = match[1]
            elsif match = /IdentityFile (.*)/.match(line)
              options[:keys] =  [match[1].gsub(/"/,'')]
            elsif match = /Port (.*)/.match(line)
              options[:port] = match[1]
            end
          end
        end

        c.ssh   = Net::SSH.start(c.host, user, options)
        c.os    = backend(Serverspec::Commands::Base).check_os
      end
    end
  end
else
  module Serverspec
    module Backend
      class Exec
        def run_command(cmd)
          if cmd =~ /invalid/
            {
              :stdout      => ::RSpec.configuration.stdout,
              :stderr      => ::RSpec.configuration.stderr,
              :exit_status => 1,
              :exit_signal => nil
            }
          else
            {
              :stdout      => ::RSpec.configuration.stdout,
              :stderr      => ::RSpec.configuration.stderr,
              :exit_status => 0,
              :exit_signal => nil
            }
          end
        end
      end
    end

    module Type
      class Base
        def command
          cmd = backend.build_command('command')
          backend.add_pre_command(cmd)
        end
      end
    end
  end
end

RSpec.configure do |c|
  c.add_setting :stdout, :default => ''
  c.add_setting :stderr, :default => ''
end
