require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spcore'

describe SPBlocks::OscillatorBlock do
  def set_port_value block, port_name, value
    port = block.find_first_port(port_name)
    return port.set_value value
  end
  
  def get_port_value block, port_name
    port = block.find_first_port(port_name)
    return port.get_value
  end

  before :all do
    @port_tests = [
      {
        "attack_time" => 0.001,
        "release_time" => 0.001
      },
      {
        "attack_time" => 0.05,
        "release_time" => 0.075
      },
      {
        "attack_time" => 0.125,
        "release_time" => 0.210
      },
      {
        "attack_time" => 0.220,
        "release_time" => 0.085
      },
    ]
  end
  
  context 'control port tests' do
    it 'should allow get/set of each control port' do
      block = SPBlocks::EnvelopeDetectorBlock.new :sample_rate => 500.0, :attack_time => 0.1, :release_time => 0.1
      @port_tests.each do |hash|
        hash.each do |name, value|
          set_port_value(block, name, value)
          get_val = get_port_value(block, name)
          get_val.should eq(value)
        end
      end
    end
  end

  context 'functional comparison test' do
    it 'should behave exactly the same as a plain SPCore::EnvelopeDetector with the same settings' do
      @port_tests.each do |hash|
        sample_rate = 500.0
        osc_freq = 50.0
        osc = SPCore::Oscillator.new :sample_rate => sample_rate, :frequency => osc_freq
        env_block = SPBlocks::EnvelopeDetectorBlock.new :sample_rate => sample_rate, :attack_time => 0.001, :release_time => 0.001
        env = SPCore::EnvelopeDetector.new :sample_rate => sample_rate, :attack_time => 0.001, :release_time => 0.001
        
        hash.each do |name, value|
          env.send((name + '=').to_sym, value)
          set_port_value(env_block, name, value)
        end
        
        n = sample_count = (5.0 * sample_rate / osc_freq).to_i
        
        osc_output = Array.new(n)
        env_output = Array.new(n)
        50.times do |i|
          osc_output[i] = osc.sample
          env_output[i] = env.process_sample osc_output[i]
        end
        
        block_receiver = SPNet::SignalInPort.new
        env_block.find_first_port("OUTPUT").add_link(block_receiver)
        
        env_block.find_first_port("INPUT").enqueue_values osc_output
        env_block.step 50
        
        block_receiver.queue.should eq(env_output)
      end
    end
  end
end
