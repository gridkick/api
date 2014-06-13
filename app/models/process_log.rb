class ProcessLog
  include App::Document

  field \
    :meta,
    :type => Hash

  field \
    :notes,
    :type => String

  field \
    :stdout,
    :type => String

  field \
    :stderr,
    :type => String

  field \
    :exit_status,
    :type => Integer

  belongs_to \
    :performed_for,
    :polymorphic => true
end
