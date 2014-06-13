class ConvertForeignInstanceData < Mongoid::Migration
  def self.up
    Instance.all.each do |instance|
      old = instance.foreign_instance_data || Hash.new
      old[:type] = instance.service_slug

      instance.foreign_instance_data = [old]
      instance.save!
    end
  end

  def self.down
    Instance.all.each do |instance|
      old = instance.foreign_instance_data.try('first') || Hash.new
      old.delete("type")

      instance.foreign_instance_data = old
      instance.save!
    end
  end
end