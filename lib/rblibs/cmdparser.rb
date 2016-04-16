
#
#
# Very simple command line options parser that returns a hash with
# the options as keys and their values if any.
# Options without values are assigned a value of true.
#
# The parse method must be called with an array of Option struct filled
# with the needed values.
#
# Possible values for Option struct:
# - key:     any suitable key for a hash
# - name:    string, the name of the option '--xxx'. if string ends with
#            a blank followed by any char(s), it's expected to have an argument.
# - options: a hash of options with any of the following symbol as key
#            - :default   : assign a default value to the option
#            - :mandatory : will raise an exception if option is not on the cmd line
#            - :call_back : a proc that will be called with the value of the option
#                           as a parameter. the returned value of the proc is then
#                           assigned to the option value.
#
#

module CmdParser

    Option = Struct.new(:key, :name, :options)

    def self.parse(opt_tab)
        h = {}
        opt_tab.each do |opt|
            # Find if opt is on command line parameters
            ix = ARGV.index(opt.name.split(' ')[0])

            # Does the option have options? (hmmm....)
            if opt.options
                # Assign default value if any
                h[opt.key] = opt.options[:default] if opt.options[:default]
                # Check if present if mandatory
                raise "Mandatory option #{opt.name}" if opt.options[:mandatory] && !ix
            end

            if ix
                if opt.name.split(' ')[1]
                    if opt.options[:call_back]
                        h[opt.key] = opt.options[:call_back].call(ARGV[ix+1])
                    else
                        h[opt.key] = ARGV[ix+1]
                    end
                else
                    h[opt.key] = true
                end
            end
        end
        return h
    end
end
