class AddDailyBackupsEnabledInstanceField < Mongoid::Migration
  
  def self.up
   Instance.all.each do |instance|
    instance.daily_backups_enabled = true
    instance.save!
   end 
  end

  def self.down
    Instance.all.each do |instance|
      instance.unset :daily_backups_enabled
      instance.save!
    end
  end
  
end
