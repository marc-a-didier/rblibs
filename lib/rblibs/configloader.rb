#!/usr/bin/env ruby

#
#
# Utility to read a json or yaml file and return it as a hash
#
# Several operations may be performed on the resulting hash by setting the
# following keys in the params array:
# - :symbolize -> Transform keys to symbols
# - :sub_env_vars -> Substitute $... occurences in strings with their environment variables value
# - :nihilize -> Set every objects responding to empty? and are empty to nil
#
#

require 'psych'

module ConfigLoader

    def self.symbolize(obj)
        return obj.reduce({}) { |h, (k, v)| h[k.to_sym] =  self.symbolize(v); h } if obj.is_a?(Hash)
        return obj.reduce([]) { |a, v     | a           << self.symbolize(v); a } if obj.is_a?(Array)
        return obj
    end

    def self.sub_env_vars(obj)
        obj.each { |k, v| self.sub_env_vars(v) } if obj.is_a?(Hash)
        obj.each { |e| self.sub_env_vars(e) } if obj.is_a?(Array)
        obj.scan(/\$[A-Z]+/).each { |m| obj.sub!(m, ENV[m[1..-1]]) } if obj.is_a?(String)
        return obj
    end

    def self.traverse(obj, &block)
        obj.each { |k, v| self.traverse(v) } if obj.is_a?(Hash)
        obj.each { |e| self.traverse(e) } if obj.is_a?(Array)
        obj = yield(obj) if block_given?
        return obj
    end

    def self.nihilize(obj)
        if obj.respond_to?(:empty?) && obj.empty?
            obj = nil
        else
            return obj.reduce({}) { |h, (k, v)| h[k.to_sym] =  self.nihilize(v); h } if obj.is_a?(Hash)
            return obj.reduce([]) { |a, v     | a           << self.nihilize(v); a } if obj.is_a?(Array)
        end
        return obj
    end

    def self.load(file_name, params = [])
        # Empty hash by default
        cfg = {}

        # Load yaml/json from file
        cfg = Psych.load_file(file_name)

        # Call each mentioned methods in params
        params.each { |op| cfg = self.send(op, cfg) }

        return cfg
    end
end
