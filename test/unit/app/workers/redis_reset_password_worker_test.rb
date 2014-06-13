require 'test_helper'

describe RedisResetPasswordWorker do
  it 'creates ansible hosts file with instance data'
  it 'builds up extra ansible vars with instance specific data'
  it 'can build the ansible command'
  
  describe :new_db_password do   
    it "returns same password for same command instnace when called 2x" do 
      worker = new_worker
      password = worker.new_db_password
      worker.new_db_password.must_equal password
    end
    it "returns different password for different woker instances" do 
      w1 = new_worker
      w2 = new_worker
      refute_equal \
        w1.new_db_password, 
        w2.new_db_password
    end
  end  
  
  it 'should return db_name equal to redis' do 
    new_worker.db_name.must_equal 'redis'
  end
  
  ### helper methods
  
  def new_worker 
    RedisResetPasswordWorker.new
  end
end
