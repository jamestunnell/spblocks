require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPBlocks::DelayBlock do
  describe '.new' do
    before :all do
      @block = SPBlocks::DelayBlock.new :sample_rate => 200.0, :max_delay_seconds => 1.0
    end
    
    it 'should have default delay time of 0.0 sec' do
      @block.find_first_port("DELAY_SEC").get_value.should eq(0.0)
    end
    
    it 'should pass through values unchanged' do
      reciever = SPNet::SignalInPort.new
      values = [ 1.0, 2.0, -1.0 ]
      @block.find_first_port("OUTPUT").add_link reciever
      @block.find_first_port("INPUT").enqueue_values values
      @block.step 3
      reciever.queue.should eq(values)
    end
  end
  
  describe "DELAY_SEC port" do
    it 'should set the delay in seconds' do
      sample_rate = 2000.0
      max_delay_sec = 1.0
      5.times do
        @block = SPBlocks::DelayBlock.new(
          :sample_rate => sample_rate,
          :max_delay_seconds => max_delay_sec
        )
        delay_samples = (sample_rate * rand * max_delay_sec).to_i
        delay_sec = delay_samples / sample_rate
        rand_sample = rand

        @reciever = SPNet::SignalInPort.new
        @block.find_first_port("OUTPUT").add_link @reciever
        @values = [rand_sample] + Array.new(delay_samples, 0.0)
        @block.find_first_port("INPUT").enqueue_values @values
  
        @block.find_first_port("DELAY_SEC").set_value(delay_sec)
        @block.step delay_samples + 1
        @reciever.queue.last.should eq(rand_sample)
      end
    end
  end
end
