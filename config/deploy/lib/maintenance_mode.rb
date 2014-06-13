namespace :maintenance_mode do
  task :on do
    sidekiq.quiet
    copy_maintenance_html
    link_maintenance_html
    sidekiq.stop
  end

  task :off do
    sidekiq.start
    remove_maintenance_html
  end

  task :copy_maintenance_html do
    path = fetch_maintenance_path
    raise 'No File Specified!' unless File.exists?( path )

    upload \
      path,
      remote_path
  end

  task :remove_maintenance_html do
    remove_if_exists symlinked_maintenance_path
    remove_if_exists shared_maintenance_path
  end

  task :link_maintenance_html do
    run <<___
if [ -e #{ shared_maintenance_path } ]; then
  ln -sf #{ shared_maintenance_path } #{ symlinked_maintenance_path };
fi
___
  end

  def shared_maintenance_path
    "#{ shared_path }/maintenance.html"
  end

  def symlinked_maintenance_path
    "#{ current_path }/public/maintenance.html"
  end

  def remove_if_exists( path )
    run "if [ -e #{ path } ]; then rm #{ path }; fi"
  end

  def remote_path
    "#{ shared_path }/maintenance.html"
  end

  def fetch_maintenance_path
    if file_path = ENV[ 'MAINTENANCE_PAGE' ]
      expanded_file_path =
        if file_path[ 0 ] == '/'
          file_path
        else
          File.expand_path "#{ root_path }/#{ file_path }"
        end
    else
      default_path
    end
  end

  def default_path
    "#{ root_path }/tmp/maintenance.html"
  end

  def root_path
    File.expand_path "#{ File.dirname __FILE__ }../../../../"
  end
end

before 'deploy:restart' , 'maintenance_mode:link_maintenance_html'
