require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spcore'

describe SPBlocks::OscillatorBlock do
  before :all do
    @port_tests = [
      {
        "WAVE_TYPE" => SPCore::Oscillator::WAVE_SINE,
        "FREQUENCY" => 150.0,
        "AMPLITUDE" => 55.0,
        "PHASE_OFFSET" => 50.0,
        "DC_OFFSET" => -2.0, 
      },
      {
        "WAVE_TYPE" => SPCore::Oscillator::WAVE_TRIANGLE,
        "FREQUENCY" => 10.0,
        "AMPLITUDE" => -1.0,
        "PHASE_OFFSET" => -0.5,
        "DC_OFFSET" => -5.0, 
      },
      {
        "WAVE_TYPE" => SPCore::Oscillator::WAVE_SQUARE,
        "FREQUENCY" => 20.0,
        "AMPLITUDE" => 11.0,
        "PHASE_OFFSET" => -25.0,
        "DC_OFFSET" => 15.0, 
      },
      {
        "WAVE_TYPE" => SPCore::Oscillator::WAVE_SAWTOOTH,
        "FREQUENCY" => 100.0,
        "AMPLITUDE" => 1.0e10,
        "PHASE_OFFSET" => 25.0,
        "DC_OFFSET" => 15.0e3
      },
    ]
  end
  
  context 'control port tests' do
    it 'should allow get/set of each control port' do
      block = SPBlocks::OscillatorBlock.new(:sample_rate => 500)
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
    it 'should behave exactly the same as a plain Oscillator with the same settings' do
      @port_tests.each do |hash|
        block = SPBlocks::OscillatorBlock.new :sample_rate => 500
        osc = SPCore::Oscillator.new :sample_rate => 500
        
        hash.each do |name, value|
          osc.send((name.downcase + '=').to_sym, value)
          block.in_ports[name].set_value value
        end
        
        n = 50
        block.step n
        
        osc_output = Array.new(n)
        n.times do |i|
          osc_output[i] = osc.sample
        end
        
        block.out_ports["OUTPUT"].queue.should eq(osc_output)
      end
    end
  end
end
