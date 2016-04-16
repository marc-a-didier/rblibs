
module Spammer

    require 'net/smtp'
    
    def self.send(config, message)
        msg = "From: #{config[:from]}\n"
        msg << "To: <#{config[:recipients].join('; ')}>\n"
        msg << "Subject: #{config[:subject]}\n\n"
        msg << message

        if config[:login]
            smtp = Net::SMTP.new(config[:server], config[:port])
            # smtp.set_debug_output(STDERR)
            smtp.enable_starttls
            # Since ruby 2.3 first param of start must NOT be empty!!!
            smtp.start('rrsync', config[:recipients].first, config[:passwd], :login) do |smtp|
                smtp.send_message(msg, config[:sender], config[:recipients])
            end
        else
            Net::SMTP.start(config[:server]) do |smtp|
                smtp.send_message(msg, config[:sender], config[:recipients])
            end
        end
    end
end
