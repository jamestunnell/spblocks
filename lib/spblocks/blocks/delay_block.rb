require 'spnet'
require 'spcore'

include SPNet

module SPBlocks
class DelayBlock < Block

  MAX_DELAY_SECONDS = 10.0
  
  def initialize args
    raise ArgumentError, "args does not have :sample_rate key" unless args.has_key?(:sample_rate)
    @delay_line = SPCore::DelayLine.new(:sample_rate => args[:sample_rate], :max_delay_seconds => MAX_DELAY_SECONDS)
    @feedback = 0.0
    @mix = 0.0
    
    input = SignalInPort.new()
    output = SignalOutPort.new()
    
    max_delay_sec = @delay_line.max_delay_seconds
    
    delay_sec = ParamInPort.new(
      :limiter => RangeLimiter.new(0.0, true, max_delay_sec, true),
      :get_value_handler => lambda { @delay_line.delay_seconds },
      :set_value_handler => lambda { |value| @delay_line.delay_seconds = value }
    )
    
    feedback = ParamInPort.new(
      :limiter => RangeLimiter.new(0.0, true, 1.0, true),
      :get_value_handler => lambda { @feedback },
      :set_value_handler => lambda { |value| @feedback = value }
    )
    
    mix = ParamInPort.new(
      :limiter => RangeLimiter.new(0.0, true, 1.0, true),
      :get_value_handler => lambda { @mix },
      :set_value_handler => lambda { |value| @mix = value }
    )
    
    algorithm = lambda do |count|
      values = input.dequeue_values count
      for i in 0...values.count
        input = values[i]
        delayed_before = @delay_line.delayed_sample
        @delay_line.push_sample(input + (@feedback * delayed_before))
        delayed_after = @delay_line.delayed_sample
        values[i] = (input * (1.0 - @mix)) + (delayed_after * @mix)
      end
      output.enqueue_values(values)
    end

    super(
      :sample_rate => @delay_line.sample_rate,
      :algorithm => algorithm,
      :in_ports => {
        "INPUT" => input,
        "DELAY_SECONDS" => delay_sec,
        "FEEDBACK" => feedback,
        "MIX" => mix
      },
      :out_ports => {
        "OUTPUT" =>  output
      },
    )
  end
end
end
