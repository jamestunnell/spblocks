require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spcore'

describe SPBlocks::OscillatorBlock do
  before :all do
    @port_tests = [
      {
        "ATTACK_TIME" => 0.001,
        "RELEASE_TIME" => 0.001
      },
      {
        "ATTACK_TIME" => 0.05,
        "RELEASE_TIME" => 0.075
      },
      {
        "ATTACK_TIME" => 0.125,
        "RELEASE_TIME" => 0.210
      },
      {
        "ATTACK_TIME" => 0.220,
        "RELEASE_TIME" => 0.085
      },
    ]
  end
  
  context 'control port tests' do
    it 'should allow get/set of each control port' do
      block = SPBlocks::EnvelopeDetectorBlock.new :sample_rate => 2000
      @port_tests.each do |hash|
        hash.each do |name, value|
          block.in_ports[name].set_value value
          get_val = block.in_ports[name].get_value
          get_val.should eq(value)
        end
      end
    end
  end

  context 'functional comparison test' do
    it 'should behave exactly the same as a plain SPCore::EnvelopeDetector with the same settings' do
      @port_tests.each do |hash|
        sample_rate = 2000
        osc_freq = 50.0
        osc = SPCore::Oscillator.new :sample_rate => sample_rate, :frequency => osc_freq
        env_block = EnvelopeDetectorBlock.new :sample_rate => sample_rate
        env_block.in_ports["ATTACK_TIME"].set_value 0.001
        env_block.in_ports["RELEASE_TIME"].set_value 0.001
        env = SPCore::EnvelopeDetector.new :sample_rate => sample_rate, :attack_time => 0.001, :release_time => 0.001
        
        hash.each do |name, value|
          env.send((name.downcase + '=').to_sym, value)
          env_block.in_ports[name].set_value value
        end
        
        n = sample_count = (5.0 * sample_rate / osc_freq).to_i
        
        osc_output = Array.new(n)
        env_output = Array.new(n)
        n.times do |i|
          osc_output[i] = osc.sample
          env_output[i] = env.process_sample osc_output[i]
        end
        
        env_block.in_ports["INPUT"].enqueue_values osc_output
        env_block.step n
        env_block.out_ports["OUTPUT"].queue.should eq(env_output)
      end
    end
  end
end
