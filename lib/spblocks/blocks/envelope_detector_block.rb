require 'spnet'
require 'spcore'

module SPBlocks
class EnvelopeDetectorBlock < SPNet::Block

  def initialize hashed_args = {}
    @env_detector = SPCore::EnvelopeDetector.new(hashed_args)
    
    attack_time_limiter = SPCore::Limiters.make_lower_limiter(0.0)
    attack_time_handler = SPNet::ControlMessage.make_handler(
      lambda {|message| message.data = @env_detector.attack_time },
      lambda { |message| @env_detector.attack_time = attack_time_limiter.call(message.data) }
    )

    release_time_limiter = SPCore::Limiters.make_lower_limiter(0.0)
    release_time_handler = SPNet::ControlMessage.make_handler(
      lambda {|message| message.data = @env_detector.release_time },
      lambda { |message| @env_detector.release_time = release_time_limiter.call(message.data) }
    )
    
    input = SPNet::SignalInPort.new(:name => "INPUT")
    output = SPNet::SignalOutPort.new(:name => "OUTPUT")
    release_time = SPNet::MessageInPort.new(:name => "RELEASE_TIME", :message_type => SPNet::Message::CONTROL, :processor => release_time_handler)
    attack_time = SPNet::MessageInPort.new(:name => "ATTACK_TIME", :message_type => SPNet::Message::CONTROL, :processor => attack_time_handler)
    
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
      :signal_in_ports => [ input ],
      :signal_out_ports => [ output ],
      :message_in_ports => [ attack_time, release_time ],
      :message_out_ports => []
    }
    super(super_args)
  end
end
end
