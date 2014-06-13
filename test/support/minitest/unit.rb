module MiniTest
  class Unit
    class TestCase
      alias_method '__assert__' , 'assert'

      ##
      #
      # TestCase#assert
      #
      # See: https://github.com/ahoward/testing.rb/blob/08dd643239a23543409ecb5fee100181f1621794/lib/testing.rb#L82-107
      #
      # Override assert to take a few different kinds of options
      #
      # Most notable argument type is a block that:
      # -> asserts no exceptions were raised
      # -> asserts the result of the block is truthy
      # -> returns the result of the block
      #
      def assert( *args , &block )
        # An options hash was passed containing assertion parameters
        if args.size == 1 and args.first.is_a?(Hash)
          options  = Map.opts args
          missing  = false

          expected = options.getopt :expected , :default => missing
          actual   = options.getopt :actual   , :default => missing

          if expected == missing and actual == missing
            actual , expected , *_ = options.to_a.flatten
          end

          # Maybe expected/actual were blocks
          actual   = actual.call()   if actual.respond_to?(:call)
          expected = expected.call() if expected.respond_to?(:call)

          assert_equal expected , actual
          return actual
        end

        ##
        #
        # Evaluate the passed block for the assertion
        #
        if block
          label   = "failed assertion(#{ args.join(' ') })"
          result  = nil
          raised  = false
          result  = begin
                      block.call
                    rescue Object => e
                      raised = e
                      false
                    end

          __assert__ !raised , ( raised.message rescue label )
          __assert__ result  , label

          return result

        ##
        #
        # Plain old `assert` with a value
        #
        else
          return __assert__( *args , &block )
        end
      end
    end
  end
end
