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
        "wave_type" => SPCore::Oscillator::WAVE_SINE,
        "frequency" => 150.0,
        "amplitude" => 55.0,
        "phase_offset" => 50.0,
        "dc_offset" => -2.0, 
      },
      {
        "wave_type" => SPCore::Oscillator::WAVE_TRIANGLE,
        "frequency" => 10.0,
        "amplitude" => -1.0,
        "phase_offset" => -0.5,
        "dc_offset" => -5.0, 
      },
      {
        "wave_type" => SPCore::Oscillator::WAVE_SQUARE,
        "frequency" => 20.0,
        "amplitude" => 11.0,
        "phase_offset" => -25.0,
        "dc_offset" => 15.0, 
      },
      {
        "wave_type" => SPCore::Oscillator::WAVE_SAWTOOTH,
        "frequency" => 100.0,
        "amplitude" => 1.0e10,
        "phase_offset" => 25.0,
        "dc_offset" => 15.0e3
      },
    ]
  end
  
  context 'control port tests' do
    it 'should allow get/set of each control port' do
      block = SPBlocks::OscillatorBlock.new :sample_rate => 500.0
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
    it 'should behave exactly the same as a plain Oscillator with the same settings' do
      @port_tests.each do |hash|
        block = SPBlocks::OscillatorBlock.new :sample_rate => 500.0
        osc = SPCore::Oscillator.new :sample_rate => 500.0
        
        hash.each do |name, value|
          osc.send((name + '=').to_sym, value)
          set_port_value(block, name, value)
        end
        
        block_receiver = SPNet::SignalInPort.new
        block.find_first_port("OUTPUT").add_link(block_receiver)
        block.step 50
        
        osc_output = Array.new(50)
        50.times do |i|
          osc_output[i] = osc.sample
        end
        
        block_receiver.queue.should eq(osc_output)
      end
    end
  end
end
