# frozen_string_literal: true

class Chronometer
  class DSL
    attr_reader :events, :tracepoints

    def initialize
      @events = []
      @tracepoints = []
    end

    def for_class(cls)
      @cls && raise('already in for_class')
      @cls = cls

      yield
    ensure
      @cls = nil
    end

    def for_singleton_class(cls, &blk)
      for_class(cls.singleton_class, &blk)
    end

    def method(method_name, **opts)
      opts[:name] ||= @cls.singleton_class? ? "#{ObjectSpace.each_object(@cls).to_a.last}.#{method_name}" : "#{@cls}##{method_name}"
      opts.delete(:method) && raise('Cannot specify :method')
      opts[:method] = method_name
      opts[:event_type] ||= :X
      opts[:cls] = @cls || raise('must be in for_class block')
      events << Event.new(**opts)
    end

    def methods(*method_names, **opts)
      method_names.flatten.each do |method_name|
        method method_name, **opts
      end
    end

    def tracepoint(event_name, &blk)
      @cls && raise('in for_class block')

      tracepoints << [event_name, blk]
    end
  end
  private_constant :DSL
end
