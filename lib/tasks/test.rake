namespace :test do
  %w(
    all
    functional
    integration
    unit
  ).each do | sub_task |
    task sub_task.to_sym => "minitest:#{ sub_task }"
  end
end

task :default => :test
task :test    => 'test:all'
