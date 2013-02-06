require 'spnet'
require 'wavefile'

module SPBlocks
class WavOutBlock < SPNet::Block

  include Hashmake::HashMakeable
  
  HASHED_ARG_SPECS = [
    Hashmake::ArgSpec.new(:reqd => true, :key => :sample_rate, :type => Float, :validator => ->(a){ (a > 0.0) && (a.to_i == a)} ),
    Hashmake::ArgSpec.new(:reqd => true, :key => :file_name, :type => String, :validator => ->(a){ !a.empty?() } ),
  ]
  
  attr_reader :file_name

  BITS_PER_SAMPLE = 32
  MAX_SAMPLE_VALUE = (2 **(0.size * 8 - 2) - 2)

  FILE_COMMANDS = [ :open, :close ]
  
  def initialize hashed_args = {}
    hash_make HASHED_ARG_SPECS, hashed_args

    @format = WaveFile::Format.new(:mono, 32, @sample_rate.to_i)
    @writer = WaveFile::Writer.new(@file_name, @format)

    input = SPNet::SignalInPort.new(:name => "INPUT", :limits => (-1.0...1.0))

    file = SPNet::CommandInPort.new(
      :name => "FILE",
      :command_map => {
        :open => lambda do |data|
          unless @writer.closed?
            @writer.close
          end
          @file_name = data
          @writer = WaveFile::Writer.new(@file_name, @format)          
        end,
        :close => lambda {|data| @writer.close }
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

    super_args = {
      :name => "WAV_OUT",
      :algorithm => algorithm,
      :in_ports => [ input, file ],
      :out_ports => [ ],
    }
    super(super_args)

  end
end
end
