# frozen_string_literal: true

require_relative 'chronometer/dsl'
require_relative 'chronometer/event'
require_relative 'chronometer/trace_event'
require_relative 'chronometer/version'

class Chronometer
  attr_reader :trace_events

  def self.from_file(path, contents: File.read(path))
    new do
      instance_eval(contents, path)
    end
  end

  def initialize(&blk)
    dsl = DSL.new
    dsl.instance_exec(&blk)
    @events = dsl.events
    @tracepoints = dsl.tracepoints
    @trace_event_queue = Queue.new
    @trace_events = []
  end

  def install!
    @events.each { |e| install_method_hook(e) }
    @tracepoints.each { |tp| install_tracepoint(tp) }
  end

  def drain!
    loop { @trace_events << @trace_event_queue.pop(true) }
  rescue ThreadError
    nil
  end

  def print_trace_event_report(dest, metadata: {})
    raise ArgumentError, 'cannot manually specify :traceEvents' if metadata.key?(:traceEvents)
    require 'json'
    File.open(dest, 'w') do |f|
      f << JSON.generate(metadata)
      f.seek(-1, :CUR) # remove closing }
      f << ',' unless metadata.empty?
      f << '"traceEvents":['
      @trace_events.each_with_index do |te, i|
        f << ',' unless i == 0
        f << JSON.generate(te.to_h)
      end
      f << ']}'
    end
  end

  def self.timestamp_us
    Time.now.utc.to_f.*(1_000_000).round
  end

  def register_trace_event(event)
    @trace_event_queue << event
  end

  private

  def install_method_hook(event)
    cls = event.cls
    method = event.method

    unbound_method = cls.instance_method(method)
    arg_labels = unbound_method.parameters.map(&:last)

    timer = self

    cls.send(:define_method, method) do |*args, &blk|
      context = event.context&.call(self)
      args_dict = arg_labels.zip(args).to_h
      args_dict[:context] = context if context

      start_time = ::Chronometer.timestamp_us

      event_type = event.event_type
      if event_type == :X
        timer.register_trace_event TraceEvent.new(
          process_id: Process.pid,
          thread_id: Thread.current.object_id,
          start_time_usec: ::Chronometer.timestamp_us,
          event_type: :B,
          name: event.name
        )
        event_type = :E
      end

      r0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      begin
        unbound_method.bind(self).call(*args, &blk)
      ensure
        duration = Process.clock_gettime(Process::CLOCK_MONOTONIC).-(r0).*(1_000_000).round

        timer.register_trace_event TraceEvent.new(
          process_id: Process.pid,
          thread_id: Thread.current.object_id,
          start_time_usec: event_type == :E ? ::Chronometer.timestamp_us : start_time,
          event_type: event_type,
          name: event.name,
          args: args_dict,
          category: event.category,
          duration: duration,
          cls: cls,
          method: method
        )
      end
    end
  end

  def install_tracepoint(tracepoint)
    event_name, blk = tracepoint
    TracePoint.trace(event_name) do |tp|
      next if tp.path == __FILE__
      args = {
        process_id: Process.pid,
        thread_id: Thread.current.object_id,
        start_time_usec: ::Chronometer.timestamp_us,
        event_type: :I,
        name: event_name
      }
      args.update blk&.call(tp)

      te = TraceEvent.new(**args)
      register_trace_event(te)
    end
  end
end
