require 'spnet'
require 'spcore'

include SPNet

module SPBlocks
class GainBlock < Block
  GAIN_MIN = -SPCore::Gain::MAX_DB_ABS
  GAIN_MAX = SPCore::Gain::MAX_DB_ABS
  
  def initialize args
    raise ArgumentError, "args does not have :sample_rate key" unless args.has_key?(:sample_rate)

    @gain_db = 0.0
    @gain_linear = 1.0

    input = SignalInPort.new()
    output = SignalOutPort.new()
    
    gain_db = ParamInPort.new(
      :limiter => RangeLimiter.new(GAIN_MIN, true, GAIN_MAX, true),
      :get_value_handler => lambda { @gain_db },
      :set_value_handler => lambda {|value| @gain_db = value; @gain_linear = SPCore::Gain.db_to_linear @gain_db }
    )
    
    algorithm = lambda do |count|
      values = input.dequeue_values count
      for i in 0...values.count
        values[i] *= @gain_linear
      end
      output.enqueue_values(values)
    end

    super(
      :sample_rate => args[:sample_rate],
      :algorithm => algorithm,
      :in_ports => { "INPUT" => input, "GAIN_DB" => gain_db },
      :out_ports => { "OUTPUT" => output },
    )
  end
end
end
