# frozen_string_literal: true

require 'claide'
require 'chronometer'

class Chronometer
  module Command; end
  class Command::Chronometer < CLAide::Command
    self.version = VERSION

    self.summary = "Trace a ruby program's execution using a chronofile"

    self.arguments = [
      CLAide::Argument.new('CHRONOFILE', true),
      CLAide::Argument.new('RUBY_FILE', true),
      CLAide::Argument.new('ARGUMENTS', false, true)
    ]

    def self.options
      [
        ['--output=TRACE', 'The path to the tracefile chronometer will write']
      ].concat(super)
    end

    def initialize(argv)
      @chronofile = argv.shift_argument
      @output = argv.option('output', "#{@chronofile}.trace")
      @file_to_load = argv.shift_argument
      @arguments = argv.remainder! if @chronofile && @file_to_load
      super
    end

    def validate!
      super
      help! 'Must supply a chronofile' unless @chronofile
      @chronofile_contents = begin
                               File.read(@chronofile)
                             rescue StandardError
                               help!("No such chronofile `#{@chronofile}`")
                             end
      help! 'Must supply a ruby file to load' unless @file_to_load
      @file_to_load = ENV.fetch('PATH', '').split(File::PATH_SEPARATOR).push('.').reduce do |a, e|
        next a if a
        a ||= File.join(e, @file_to_load)
        a &&= nil unless File.file?(a)
        a
      end
      help! "Could not find `#{@file_to_load}`" unless @file_to_load
    end

    def run
      argv = ::ARGV.dup
      ::ARGV.replace(@arguments)
      time { load(@file_to_load) }
    ensure
      ::ARGV.replace(argv)
    end

    private

    def time
      timer = ::Chronometer.from_file(@chronofile, contents: @chronofile_contents)
      timer.install!

      begin
        yield
      ensure
        timer.drain!
        timer.print_trace_event_report(@output, metadata: { meta_success: $ERROR_INFO.nil? })
      end
    end
  end
end
