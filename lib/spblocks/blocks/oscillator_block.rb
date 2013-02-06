require 'spnet'
require 'spcore'

module SPBlocks
class OscillatorBlock < SPNet::Block

  def initialize hashed_args = {}
    @oscillator = SPCore::Oscillator.new(hashed_args)

    output = SPNet::SignalOutPort.new(:name => "OUTPUT")
    
    wave_type_limiter = SPCore::Limiters.make_enum_limiter(SPCore::Oscillator::WAVES)
    wave_type = SPNet::ValueInPort.new(
      :name => "WAVE_TYPE",
      :get_value_handler => lambda { @oscillator.wave_type },
      :set_value_handler => lambda { |value| @oscillator.wave_type = wave_type_limiter.call(value, @oscillator.wave_type) }
    )
    
    freq_limiter = SPCore::Limiters.make_range_limiter(0.01..(@oscillator.sample_rate / 2.0))
    frequency = SPNet::ValueInPort.new(
      :name => "FREQUENCY",
      :get_value_handler => lambda { @oscillator.frequency },
      :set_value_handler => lambda { |value| @oscillator.frequency = freq_limiter.call(value) }
    )

    amplitude = SPNet::ValueInPort.new(
      :name => "AMPLITUDE",
      :get_value_handler => lambda { @oscillator.amplitude },
      :set_value_handler => lambda { |value| @oscillator.amplitude = value }
    )
    
    phase_offset = SPNet::ValueInPort.new(
      :name => "PHASE_OFFSET",
      :get_value_handler => lambda { @oscillator.phase_offset },
      :set_value_handler => lambda { |value| @oscillator.phase_offset = value }
    )
    
    dc_offset = SPNet::ValueInPort.new(
      :name => "DC_OFFSET",
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

    super_args = {
      :name => "DELAY",
      :algorithm => algorithm,
      :in_ports => [ wave_type, frequency, amplitude, phase_offset, dc_offset ],
      :out_ports => [ output ],
    }
    super(super_args)
  end
end
end
