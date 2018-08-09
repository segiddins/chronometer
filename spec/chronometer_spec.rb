# frozen_string_literal: true

require 'json'
require 'open3'

RSpec.describe Chronometer do
  it 'has a version number' do
    expect(Chronometer::VERSION).not_to be nil
  end

  it 'does something useful' do
    _stdout, stderr, status = Open3.capture3('bundle', 'exec', 'exe/chronometer', 'chronometer.chronofile', '--', 'exe/chronometer', '--version')
    expect(status).to be_success, stderr

    tracefile = File.expand_path('../chronometer.chronofile.trace', __dir__)
    expect(JSON.parse(File.read(tracefile)))
      .to have_key 'traceEvents'
  end
end
