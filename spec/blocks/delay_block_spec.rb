require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPBlocks::DelayBlock do
  describe '.new' do
    before :each do
      @block = SPBlocks::DelayBlock.new :sample_rate => 200
    end
    
    it 'should have default delay time of 0.0 sec' do
      @block.in_ports["DELAY_SECONDS"].get_value.should eq(0.0)
    end
    
    it 'should pass through values unchanged' do
      values = [ 1.0, 2.0, -1.0 ]
      @block.in_ports["INPUT"].enqueue_values values
      @block.step 3
      @block.out_ports["OUTPUT"].queue.should eq(values)
    end
  end
  
  describe "DELAY_SECONDS port" do
    it 'should set the delay in seconds' do
      sample_rate = 2000
      5.times do
        block = SPBlocks::DelayBlock.new(:sample_rate => sample_rate)
        
        delay_samples = (sample_rate * rand * DelayBlock::MAX_DELAY_SECONDS).to_i
        delay_sec = delay_samples / sample_rate
        rand_sample = rand

        values = [rand_sample] + Array.new(delay_samples, 0.0)
        block.in_ports["INPUT"].enqueue_values values
        block.in_ports["DELAY_SECONDS"].set_value(delay_sec)
        block.step delay_samples + 1        
        block.out_ports["OUTPUT"].queue.first.should eq(rand_sample)
      end
    end
  end
end
