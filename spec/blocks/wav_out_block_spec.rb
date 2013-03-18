require 'wavefile'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPBlocks::WavOutBlock do
  describe 'writing a file' do
    it 'should write values that can be read back later' do
      filename = "file_out_block_spec.wav"
      block = SPBlocks::WavOutBlock.new :sample_rate => 22050.0
      block.in_ports["FILE"].exec_command :open, filename
      values = [0.1,0.2,0.3,0.4,0.5]
      block.in_ports["INPUT"].enqueue_values values
      block.step values.count
      block.in_ports["FILE"].exec_command :close, nil
      
      reader = WaveFile::Reader.new(filename).each_buffer(values.size) do |buffer|
        converted_samples = buffer.samples.map {|sample| sample.to_f / SPBlocks::WavOutBlock::MAX_SAMPLE_VALUE }
        converted_samples.each_index do |i|
          converted_samples[i].should be_within(1e-9).of(values[i])
        end
      end
    end    
  end
end
