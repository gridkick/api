class Admin::ProcessLogsController < Admin::Base
  def index
    @process_logs = ProcessLog.desc(:created_at).limit(20)
  end
end
