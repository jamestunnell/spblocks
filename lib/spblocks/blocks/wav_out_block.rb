require 'spnet'
require 'wavefile'

module SPBlocks
class WavOutBlock < SPNet::Block
  attr_reader :file_name

  BITS_PER_SAMPLE = 32
  MAX_SAMPLE_VALUE = (2 **(0.size * 8 - 2) - 2)

  FILE_COMMANDS = [ :open, :close, :get_filename ]
  
  def initialize args
    raise ArgumentError, "args does not have :sample_rate key" unless args.has_key?(:sample_rate)
    @sample_rate = args[:sample_rate]

    @file_name = ''
    @format = WaveFile::Format.new(:mono, 32, @sample_rate.to_i)
    @writer = nil

    input = SPNet::SignalInPort.new(:limiter => RangeLimiter.new(-1.0, true, 1.0, true))

    file = SPNet::CommandInPort.new(
      :command_map => {
        :open => lambda do |data|
          unless @writer.nil? || @writer.closed?
            @writer.close
          end
          @file_name = data
          @writer = WaveFile::Writer.new(@file_name, @format)          
        end,
        :close => lambda {|data| @writer.close },
        :get_filename => lambda {|data| @filename }
      }
    )
    
    algorithm = lambda do |count|
      values = input.dequeue_values count
      unless @writer.closed?
        int_values = values.map { |value| (value * MAX_SAMPLE_VALUE).to_i }
        buffer = WaveFile::Buffer.new(int_values, @format)
        @writer.write(buffer)
      end
    end
    
    super(
      :sample_rate => @sample_rate,
      :algorithm => algorithm,
      :in_ports => { "INPUT" => input, "FILE" => file },
    )
  end
end
end
