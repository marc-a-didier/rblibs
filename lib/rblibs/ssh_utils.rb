
require 'net/ssh'

# Extends Net::SSH... with custom method
class Net::SSH::Connection::Session

    def ssh_exec(command, logger = nil, verbose = true)
        output = ''
        exit_code = exit_signal = nil
        self.open_channel do |channel|
            logger.info("Executing command: #{command}") if logger
            channel.exec(command) do |ch, success|
                unless success
                    logger.warn('Remote execution of command failed') if logger
                    return [output, -1]
                end

                # Data from stdout
                channel.on_data do |ch, data|
                    output += data
                    print(data) if verbose
                end

                # Data from stderr
                channel.on_extended_data do |ch, type, data|
                    output += data
                    print(data) if verbose
                end

                channel.on_request('exit-status') { |ch, data| exit_code = data.read_long }
                channel.on_request('exit-signal') { |ch, data| exit_signal = data.read_long }
            end
        end

        self.loop

        if logger
            logger.info("Command output: #{output}") unless output.empty?
            logger.info("Command exit code: #{exit_code}")
            logger.info("Command exit signal: #{exit_signal}")
        end

        exit_code = exit_signal if exit_code == 0 && exit_signal

        return [output, exit_code]
    end

end

module SSHUtils

    DEF_OPTS = {
                 :non_interactive => true,
                 :user_known_hosts_file => '/dev/null',
                 :keepalive => true,
                 :keepalive_interval => 60,
                 :max_pkt_size => 0x10000
               }

    def self.connect(*args)
        while true
            begin
                ssh = Net::SSH.start(*args)
                break
            rescue Errno::ECONNREFUSED, Errno::ECONNRESET, Net::SSH::ConnectionTimeout => ex
                puts("#{args[0]}: #{ex.class} Retrying...")
                sleep(1)
            end
        end
        return ssh
    end

    def self.connect_with_credentials(host, credentials, options = nil)
        options = DEF_OPTS.clone unless options

        options[:port] = credentials['port'] || 22
        if credentials['password']
            options[:password] = credentials['password']
        else
            options[:keys] = [credentials['ssh-key']]
        end

        return self.connect(host, credentials['user'], options)
    end
end
