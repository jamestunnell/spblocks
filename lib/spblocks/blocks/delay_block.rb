require 'spnet'
require 'spcore'

module SPBlocks
class DelayBlock < SPNet::Block

  include Hashmake::HashMakeable
  
  HASHED_ARG_SPECS = [
    Hashmake::ArgSpec.new(:reqd => false, :key => :feedback, :type => Numeric, :default => 0.0, :validator => ->(a){ a.between? 0.0, 1.0 } ),
    Hashmake::ArgSpec.new(:reqd => false, :key => :mix, :type => Numeric, :default => 1.0, :validator => ->(a){ a.between? 0.0, 1.0 } ),
  ]

  def initialize hashed_args = {}
    hash_make DelayBlock::HASHED_ARG_SPECS, hashed_args
    
    @delay_line = SPCore::DelayLine.new(hashed_args)
    
    input = SPNet::SignalInPort.new(:name => "INPUT")
    output = SPNet::SignalOutPort.new(:name => "OUTPUT")
    
    delay_limiter = SPCore::Limiters.make_range_limiter(0.0..@delay_line.max_delay_seconds)
    delay_sec = SPNet::ValueInPort.new(
      :name => "DELAY_SEC",
      :get_value_handler => lambda { @delay_line.delay_seconds },
      :set_value_handler => lambda { |value| @delay_line.delay_seconds = delay_limiter.call(value) }
    )
    
    feedback_limiter = SPCore::Limiters.make_range_limiter(0.0..1.0)
    feedback = SPNet::ValueInPort.new(
      :name => "FEEDBACK",
      :get_value_handler => lambda { @feedback },
      :set_value_handler => lambda { |value| @feedback = feedback_limiter.call(value) }
    )
    
    mix_limiter = SPCore::Limiters.make_range_limiter(0.0..1.0)
    mix = SPNet::ValueInPort.new(
      :name => "MIX",
      :get_value_handler => lambda { @mix },
      :set_value_handler => lambda { |value| @mix = mix_limiter.call(value) }
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
      output.send_values(values)
    end

    super_args = {
      :name => "DELAY",
      :algorithm => algorithm,
      :in_ports => [ input, delay_sec, feedback, mix ],
      :out_ports => [ output ],
    }
    super(super_args)
  end
end
end
