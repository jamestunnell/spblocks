require 'spnet'
require 'spcore'

include SPNet

module SPBlocks
class OscillatorBlock < Block

  def initialize args = {}
    raise ArgumentError, "args does not have :sample_rate key" unless args.has_key?(:sample_rate)
    @oscillator = SPCore::Oscillator.new(:sample_rate => args[:sample_rate])

    output = SignalOutPort.new()

    wave_type = ParamInPort.new(
      :limiter => EnumLimiter.new(SPCore::Oscillator::WAVES),
      :get_value_handler => lambda { @oscillator.wave_type },
      :set_value_handler => lambda { |value| @oscillator.wave_type = value }
    )
    
    frequency = ParamInPort.new(
      :limiter => RangeLimiter.new(0.0, true, @oscillator.sample_rate / 2.0, true),
      :get_value_handler => lambda { @oscillator.frequency },
      :set_value_handler => lambda { |value| @oscillator.frequency = value }
    )

    amplitude = ParamInPort.new(
      :get_value_handler => lambda { @oscillator.amplitude },
      :set_value_handler => lambda { |value| @oscillator.amplitude = value }
    )
    
    phase_offset = ParamInPort.new(
      :get_value_handler => lambda { @oscillator.phase_offset },
      :set_value_handler => lambda { |value| @oscillator.phase_offset = value }
    )
    
    dc_offset = ParamInPort.new(
      :get_value_handler => lambda { @oscillator.dc_offset },
      :set_value_handler => lambda { |value| @oscillator.dc_offset = value }
    )
    
    algorithm = lambda do |count|
      values = Array.new(count)
      count.times do |i|
        values[i] = @oscillator.sample
      end
      output.send_values(values)
    end

    super(
      :sample_rate => @oscillator.sample_rate,
      :algorithm => algorithm,
      :in_ports => { "WAVE_TYPE" => wave_type, "FREQUENCY" => frequency, "AMPLITUDE" => amplitude, "PHASE_OFFSET" => phase_offset, "DC_OFFSET" => dc_offset },
      :out_ports => { "OUTPUT" => output },      
    )
  end
end
end
