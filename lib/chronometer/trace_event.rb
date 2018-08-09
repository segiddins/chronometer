# frozen_string_literal: true

class Chronometer
  class TraceEvent
    attr_reader :process_id, :thread_id, :start_time_usec, :event_type, :name, :args, :category, :duration, :cls, :method, :sub_slices

    def initialize(process_id: nil, thread_id: nil, start_time_usec: nil, event_type: nil, name: nil, args: nil, category: nil, duration: nil, cls: nil, method: nil, sub_slices: [])
      @process_id = process_id
      @thread_id = thread_id
      @start_time_usec = start_time_usec
      @event_type = event_type
      @name = name
      @args = args
      @category = category
      @duration = duration
      @cls = cls
      @method = method
      @sub_slices = sub_slices
    end

    def to_h
      compact_hash(
        pid: process_id,
        tid: thread_id,
        ts: start_time_usec,
        ph: event_type,
        name: name,
        args: args,
        cat: category,
        dur: duration
      )
    end

    def self_time
      sub_slices.reduce(duration) { |a, e| a - e.duration }
    end

    if {}.respond_to?(:compact)
      def compact_hash(hash)
        hash.compact
      end
    else
      def compact_hash(hash)
        hash.reject { |_k, v| v.nil? }
      end
    end
  end
  private_constant :TraceEvent
end
