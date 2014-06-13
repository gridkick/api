module InstancesHelper 
  
  def instance_name(instance)
    case instance.service_slug
    when "all"
      "Postgres + Redis"
    else
      instance.service_slug
    end
  end  

end
