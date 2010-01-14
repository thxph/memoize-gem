# -*- encoding: utf-8 -*-

module Memoize
  module ClassMethods

    # Enable memoization for the following <em>methods</em>,
    # in order to enable memoization for a singleton method,
    # this must be invoked by the singleton Class
    def enable_memory(*methods)
      methods.each { |method|
        original_method = "_original_#{method}_"
        alias_method(original_method, method)  unless method_defined? original_method
        memory = {}
        undef_method method
        define_method method do |*args|
          orig_args = Marshal.load(Marshal.dump(args))
          memory[orig_args] ||= send(original_method, *args)
        end
      }
    end

    # Disable memoization for the following <em>methods</em>,
    # in order to disable memoization for a singleton method,
    # this must be invoked by the singleton Class
    def disable_memory(*methods)
      methods.each { |method|
        original_method = "_original_#{method}_"
        return  unless method_defined? original_method
        undef_method method  if method_defined? method
        alias_method method, original_method
        undef_method original_method
      }
    end

    # Enable memoization for the following <em>methods</em>
    def enable_memoization(*methods) end

    # Disable memoization for the following <em>methods</em>
    def disable_memoization(*methods) end

    ["enable", "disable"].each { |state|
      define_method "#{state}_memoization" do |*methods|
        methods.each { |method|
          (method_defined?(method) ? self : (class << self; self; end)).send "#{state}_memory", method
        }
      end
    }

    # Reset memoization for the following <em>methods</em>
    alias_method :reset_memoization, :enable_memoization

    private :enable_memory, :disable_memory
  end

  def self.included(receiver)
    receiver.send :extend, ClassMethods
    class << receiver
      extend ClassMethods
    end
  end
end

