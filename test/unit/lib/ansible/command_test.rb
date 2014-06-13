require 'test_helper'

describe Ansible::Command do
  
  describe :binary do
    it { new_instance.binary.must_equal 'ansible-playbook' }
  end
  
  describe :ansible_ssh_user do 
    it { new_instance.ansible_ssh_user.must_equal 'gridkickbackup' }
  end
    
  describe :compiled_extra_vars do 
    it :fixme
  end
  
  describe :default_hash do 
    it 'should raise NotImplementedError' do 
      proc{ new_instance.default_hash }.must_raise NotImplementedError
    end
  end
  
  describe :playbook do 
    it 'should raise NotImplementedError' do 
      proc{ new_instance.playbook }.must_raise NotImplementedError
    end
  end
  
  describe :to_s do 
    it 'joins :binary, :playbook, :hosts_file_path, :compiled_extra_vars' do 
      i = new_instance
      i.expects( :playbook ).returns 'testing'
      i.expects( :hosts_file_path ).returns 'some_path'
      i.expects( :compiled_extra_vars ).returns '--key value'
      
      i.to_s.must_equal "ansible-playbook testing -i some_path --extra-vars '--key value'"
    end
  end

  ##### helper methods

  def new_instance(instance = nil, hosts_file_path = nil)
    i = instance || Instance.new
    h = hosts_file_path ||  "some_path"
    klass.new(h, i)
  end
  
  def klass
    @_k1 ||= Class.new { include Ansible::Command }
  end
end
