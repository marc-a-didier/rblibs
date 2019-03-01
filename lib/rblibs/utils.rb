
class String
    def colorize(color_code)
        "\e[#{color_code}m#{self}\e[0m"
    end

    def black;   colorize(30); end
    def red;     colorize(31); end
    def green;   colorize(32); end
    def brown;   colorize(33); end
    def blue;    colorize(34); end
    def magenta; colorize(35); end
    def cyan;    colorize(36); end
    def gray;    colorize(37); end

    def bold;    colorize(1);  end
    def blink;   colorize(5);  end
    def invert;  colorize(7);  end

    def uncolorize; self.gsub(/\e\[(\d+)(;\d+)*m/m, ''); end
end

module Utils
    def self.symbolize(obj)
        return obj.reduce({}) { |h, (k, v)| h[k.to_sym] =  self.symbolize(v); h } if obj.is_a?(Hash)
        return obj.reduce([]) { |a, v     | a           << self.symbolize(v); a } if obj.is_a?(Array)
        return obj
    end
end
