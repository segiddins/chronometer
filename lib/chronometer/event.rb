# frozen_string_literal: true

class Chronometer
  class Event
    attr_reader :cls, :method, :name, :category, :event_type, :context

    def initialize(cls: nil, method: nil, name: nil, category: nil, event_type: nil, context: nil)
      @cls = cls
      @method = method
      @name = name
      @category = category
      @event_type = event_type
      @context = context
    end
  end
  private_constant :Event
end
