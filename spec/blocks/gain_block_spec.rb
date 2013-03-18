require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPBlocks::GainBlock do
  describe '.new' do
    before :all do
      @block = SPBlocks::GainBlock.new :sample_rate => 4
    end
    
    it 'should have default gain of 0 db' do
      @block.in_ports["GAIN_DB"].get_value.should eq(0.0)
    end
    
    it 'should pass through values unchanged' do
      reciever = SPNet::SignalInPort.new
      SPNet::Link.new(:from => @block.out_ports["OUTPUT"], :to => reciever).activate
      values = [ 1.0, 2.0, -1.0 ]
      @block.in_ports["INPUT"].enqueue_values values
      @block.step 3
      reciever.queue.should eq(values)
    end
  end
  
  describe "GAIN_DB port" do
    before :each do
      @block = SPBlocks::GainBlock.new :sample_rate => 4
      @reciever = SPNet::SignalInPort.new
      SPNet::Link.new(:from => @block.out_ports["OUTPUT"], :to => @reciever).activate
      @values = [ 1.0, 2.0, -1.0 ]
      @block.in_ports["INPUT"].enqueue_values @values
    end

    it 'should set gain to -20.0' do
      @block.in_ports["GAIN_DB"].set_value(-20.0)
      @block.step 3
      @reciever.queue.first.should eq(SPCore::Gain.db_to_linear(-20.0) * @values.first)
    end
    
    it 'should set gain to +20.0' do
      @block.in_ports["GAIN_DB"].set_value(20.0)
      @block.step 3
      @reciever.queue.first.should eq(SPCore::Gain.db_to_linear(20.0) * @values.first)
    end
  end
end
