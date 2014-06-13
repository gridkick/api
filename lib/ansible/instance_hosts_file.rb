require 'tempfile'

module Ansible
  class InstanceHostsFile < Tempfile
    attr_reader :instance

    def self.build( *args , &block )
      f = new *args , &block
      f.build!
      f
    end

    def initialize( instance )
      @instance = instance
      super instance.id.to_s
    end

    def build!
      puts instance.foreign_instance_data.first[ 'host' ]
      flush
    end
  end
end
