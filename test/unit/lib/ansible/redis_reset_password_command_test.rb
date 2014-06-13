require 'test_helper'

describe Ansible::RedisResetPasswordCommand do
  
  it :playbook do 
    new_instance.playbook.must_equal 'redis_reset_password.yml'
  end
  
  it 'new_db_password is set by initializer method' do
    new_instance("i", "h", "abc").new_db_password.must_equal 'abc'
  end
  
  ### helper methods

  def new_instance(instance = nil, hosts_file_path = nil, password = nil)
    i = instance          || Instance.new
    h = hosts_file_path   || "some_path"
    p = password          || "password"
    Ansible::RedisResetPasswordCommand.new(h, i, p)
  end
end
