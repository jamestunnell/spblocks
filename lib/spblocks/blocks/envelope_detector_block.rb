require 'spnet'
require 'spcore'

module SPBlocks
class EnvelopeDetectorBlock < SPNet::Block

  def initialize hashed_args = {}
    @env_detector = SPCore::EnvelopeDetector.new(hashed_args)
    
    input = SPNet::SignalInPort.new(:name => "INPUT")
    output = SPNet::SignalOutPort.new(:name => "OUTPUT")
    
    release_time_limiter = SPCore::Limiters.make_lower_limiter(0.0)
    release_time = SPNet::ValueInPort.new(
      :name => "RELEASE_TIME",
      :get_value_handler => lambda { @env_detector.release_time},
      :set_value_handler => lambda { |value| @env_detector.release_time = release_time_limiter.call(value) }
    )
    
    attack_time_limiter = SPCore::Limiters.make_lower_limiter(0.0)
    attack_time = SPNet::ValueInPort.new(
      :name => "ATTACK_TIME",
      :get_value_handler => lambda { @env_detector.attack_time},
      :set_value_handler => lambda { |value| @env_detector.attack_time = attack_time_limiter.call(value) }
    )
    
    algorithm = lambda do |count|
      values = input.dequeue_values count
      for i in 0...values.count
        values[i] = @env_detector.process_sample(values[i])
      end
      output.send_values(values)
    end

    super_args = {
      :name => "ENVELOPE_DETECTOR",
      :algorithm => algorithm,
      :in_ports => [ input, attack_time, release_time ],
      :out_ports => [ output ],
    }
    super(super_args)
  end
end
end
