# frozen_string_literal: true

require 'json'

RSpec.describe Chronometer do
  it 'has a version number' do
    expect(Chronometer::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(system('bundle', 'exec', 'exe/chronometer', 'chronometer.chronofile', '--', 'exe/chronometer', '--version', out: '/dev/null'))
      .to eq true

    tracefile = File.expand_path('../chronometer.chronofile.trace', __dir__)
    expect(JSON.parse(File.read(tracefile)))
      .to have_key 'traceEvents'
  end
end
