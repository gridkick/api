module Ansible
  class Process
    attr_accessor :log

    attr_reader \
      :status,
      :stderr,
      :stdout

    class << self
      alias_method \
        :for_open3,
        :new
    end

    def self.for_systemu( *args , &block )
      status = args.shift
      stdout = args.shift
      stderr = args.shift

      new \
        stdout,
        stderr,
        status,
        *args,
        &block
    end

    def initialize( stdout , stderr , status , *args , &block )
      @stdout = stdout
      @stderr = stderr
      @status = status
    end

    def determine_status
      return false if exit_status.nonzero?
      return false if stderr.present?
      return false unless status_line.present?

      stats[ 'unreachable' ] <= 0 && stats[ 'failed' ] <= 0
    end

    def exit_status
      status.exitstatus
    end

    def fail?
      !success?
    end

    alias_method \
      :failure?,
      :fail?

    alias_method \
      :failed?,
      :fail?

    def stats
      @_stats ||=
        status_line.split( ':' ).last.split.reduce Hash.new do | memo , stat |
          stat = stat.split '='
          memo[ stat[ 0 ] ] = stat[ 1 ].to_i
          memo
        end
    end

    def status_line
      @_status_line ||=
        stdout.lines.to_a.reverse.detect do | line |
          line =~ /ok.+?changed.+?unreachable.+?failed/
        end
    end

    def success?
      @_success ||= determine_status
    end

    alias_method \
      :successful?,
      :success?

    alias_method \
      :succeeded?,
      :success?
  end
end
