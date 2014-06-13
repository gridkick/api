class States < Map
  def self.for( *states )
    states_hash =
      states.flatten.inject( Hash.new ) do | memo , state |
        memo.tap do | memo |
          memo[ state.to_sym ] = state.to_s
        end
      end

    new states_hash
  end
end
