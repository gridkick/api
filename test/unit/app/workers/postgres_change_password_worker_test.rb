require 'test_helper'

describe PostgresChangePasswordWorker do 
  # it "should change the postres foreign_instance_data" do     
  #   redis = 
  #     [
  #         {"host"=>"107.170.38.238", "id"=>1154168, "port"=>9161, "name"=>"adv-local-all-52fe5813fade00064f000011", "type"=>["redis"]},
  #         {"host"=>"107.170.38.238", "id"=>1154168, "port"=>9181, "name"=>"adv-local-all-52fe5813fade00064f000011", "type"=>["postgres"]}
  #     ]
    
  #   i = Instance.new 
  #   i.foreign_instance_data = []
  #   i.foreign_instance_data << redis
  #   i.foreign_instance_data << postgres
    
  #   worker = PostgresChangePasswordWorker.new
  #   worker.instance = i
  #   new_pasword = "abc"
  #   worker.persist_new_password_for( i, new_pasword )
    
  #   postgres_hash = i.foreign_instance_data.first{ |hash| hash['type'].try(:first) == 'postgres' }
  #   postgres_hash['password'].must_equal new_pasword
  # end
end

