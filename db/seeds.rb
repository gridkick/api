if ENV[ 'SEED' ]
  load_seed ENV[ 'SEED' ]
else
  load_all_seeds!
end

BEGIN {
  def load_all_seeds!
    seed_paths.each do | seed |
      load_seed seed
    end
  end

  def load_seed( path )
    path =
      if path =~ /\A\/|~/
        path
      else
        "#{ Rails.root }/db/seeds/#{ path }"
      end

    if File.exists?( path )
      puts "Seeding path: #{ path }"
      load path
    else
      puts "Skipping path: #{ path }"
    end
  end

  def seed_paths
    [
      'boot.rb',
      Dir[ 'boot/**/**.rb' ],
      "#{ Rails.env }.rb",
      Dir[ "#{ Rails.env }/**/**.rb" ],
      'all.rb',
      Dir[ "all/**/**.rb" ]
    ].flatten
  end
}
