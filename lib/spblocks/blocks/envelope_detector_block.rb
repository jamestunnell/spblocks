require 'spnet'
require 'spcore'

include SPNet

module SPBlocks
class EnvelopeDetectorBlock < SPNet::Block
  def initialize args
    raise ArgumentError, "args does not have :sample_rate key" unless args.has_key?(:sample_rate)
    sample_rate = args[:sample_rate]
    min_time = 1.0 / sample_rate
    @env_detector = SPCore::EnvelopeDetector.new(:sample_rate => sample_rate, :attack_time => min_time, :release_time => min_time)
    
    input = SPNet::SignalInPort.new
    output = SPNet::SignalOutPort.new

    release_time = SPNet::ParamInPort.new(
      :limiter => LowerLimiter.new(min_time, true),
      :get_value_handler => lambda { @env_detector.release_time},
      :set_value_handler => lambda { |value| @env_detector.release_time = value }
    )
    
    attack_time = SPNet::ParamInPort.new(
      :limiter => LowerLimiter.new(min_time, true),
      :get_value_handler => lambda { @env_detector.attack_time},
      :set_value_handler => lambda { |value| @env_detector.attack_time = value }
    )
    
    algorithm = lambda do |count|
      values = input.dequeue_values count
      for i in 0...values.count
        values[i] = @env_detector.process_sample(values[i])
      end
      output.send_values(values)
    end

    super(
      :sample_rate=> sample_rate,
      :algorithm => algorithm,
      :in_ports => { "INPUT" => input, "ATTACK_TIME" => attack_time, "RELEASE_TIME" => release_time },
      :out_ports => { "OUTPUT" => output }
    )
  end
end
end
