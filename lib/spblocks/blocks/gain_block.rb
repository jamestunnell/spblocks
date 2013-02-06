require 'spnet'
require 'spcore'

module SPBlocks
class GainBlock < SPNet::Block
  include Hashmake::HashMakeable
  
  GAIN_MIN = -SPCore::Gain::MAX_DB_ABS
  GAIN_MAX = SPCore::Gain::MAX_DB_ABS
  
  HASHED_ARG_SPECS = [
    Hashmake::ArgSpec.new(:reqd => false, :key => :gain_db, :type => Float, :default => 0.0, :validator => ->(a){ a >= GAIN_MIN && a <= GAIN_MAX } ),
  ]
  
  def initialize args = {}
    hash_make HASHED_ARG_SPECS, args
    @gain_linear = SPCore::Gain.db_to_linear @gain_db

    input = SPNet::SignalInPort.new(:name => "INPUT")
    output = SPNet::SignalOutPort.new(:name => "OUTPUT")
    
    limiter = SPCore::Limiters.make_range_limiter(GAIN_MIN..GAIN_MAX)
    gain_db = SPNet::ValueInPort.new(
      :name => "GAIN_DB", 
      :get_value_handler => lambda { @gain_db },
      :set_value_handler => lambda {|value| @gain_db = limiter.call(value); @gain_linear = SPCore::Gain.db_to_linear @gain_db }
    )
    
    algorithm = lambda do |count|
      values = input.dequeue_values count
      for i in 0...values.count
        values[i] *= @gain_linear
      end
      output.send_values(values)
    end

    super_args = {
      :name => "GAIN",
      :algorithm => algorithm,
      :in_ports => [ input, gain_db ],
      :out_ports => [ output ],
    }
    super(super_args)
  end
end
end
