require 'test_helper'

class EnableDailyBackupsWorkerTest < ActiveSupport::TestCase
  it 'creates an ansible hosts file using instance data' do
    i = Instance.new :foreign_instance_data => [{ 'host' => '1.2.3.4' }]
    w = EnableDailyBackupsWorker.new
    f = w.build_hosts_file( i )
    f.rewind

    f.readlines.join.must_match i.foreign_instance_data.first[ 'host' ]

    f.close!
  end

  it 'builds up extra ansible vars with instance specific data' do
    w = EnableDailyBackupsWorker.new
    i = instance_with_data
    a = i.user.iam_user
    ev = w.build_command i
    ev.must_match a.access_key_id
  end

  it 'can build the ansible command' do
    w   = EnableDailyBackupsWorker.new
    i   = instance_with_data
    cmd = w.build_command i

    cmd.wont_be_empty

    w.hosts_file.close!
  end

  xit 'runs the command' do
    w = EnableDailyBackupsWorker.new
    i = instance_with_data

    assert{ w.perform i }
  end

  def instance_with_data
    i = Instance.new
    
    hash = {}
    hash[ 'host'      ] = '1.2.3.4'
    hash[ 'password'  ] = 'pw'
    hash[ 'port'      ] = 212121
    hash[ 'username'  ] = 'user'
    
    i.foreign_instance_data ||= Array.new
    i.foreign_instance_data.push( hash )

    u = i.build_user
    a = u.build_iam_user
    a.access_key_id = 'RANDOMAKI'
    a.secret_access_key = 'sak'

    i
  end
end
