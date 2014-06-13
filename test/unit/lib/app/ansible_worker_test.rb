require 'test_helper'

describe App::AnsibleWorker do 
  
  it "pulls the ansible deploy dir from the ENV" do 
    cache = ENV[ 'ANSIBLE_DEPLOY_DIR' ]
    val = 'val'
    ENV[ 'ANSIBLE_DEPLOY_DIR' ] = val

    aw = klass.new
    aw.ansible_deploy_dir.must_equal val

    ENV[ 'MYSQL_INSTANCE_USERNAME' ] = cache
  end
  
  it "builds the Ansible hosts file" do 
    i = "__instance__"
    Ansible::InstanceHostsFile.expects( :build ).with( i )
    aw = klass.new
    aw.build_hosts_file  i
  end
  
  it "instance_for" do 
    aw = klass.new 
    Instance.expects( :for )
    aw.instance_for "abc123"
  end
  
  it "forces ruby class to implement the build command" do 
    i = Instance.new
    aw = klass.new
    proc{ aw.build_command( i ) }.must_raise NotImplementedError
  end
  
  def klass
    @_k1 = Class.new { include App::AnsibleWorker }
  end
  
end

