require 'spnet'
#require 'wavefile.rb'
#
#module SPBlocks
#class FileInBlock < SPNet::Block
#  def initialize
#    output = SPNet::SignalOutPort.new(:name => "OUTPUT")
#    
#    algorithm = lambda do |count|
#      values = Array.new(count)
#      count.times do |i|
#        values[i] = @oscillator.sample
#      end
#      output.send_values(values)
#    end
#
#    super_args = {
#      :name => "FILE_IN",
#      :algorithm => algorithm,
#      :signal_in_ports => [ ],
#      :signal_out_ports => [ output ],
#      :message_in_ports => [ ],
#      :message_out_ports => [ ]
#    }
#    super(super_args)
#
#  end
#end
#end
