class Instance
  include App::Document

  field \
    :service_slug,
    :type => String

  field \
    :name,
    :type => String

  field \
    :foreign_instance_data,
    :type => Array
  
  field \
    :daily_backups_enabled, 
    :type => Boolean, 
    :default => true
    

  belongs_to :availability_zone
  belongs_to :user
  has_many :service_requests

  has_many \
    :process_logs,
    :as => :performed_for

  index \
    :user_id => 1,
    :service_slug => 1
  
  scope :initialized, -> { where(state: 'initialized') } 
  scope :provisioning, -> { where(state: 'provisioning') }
  scope :running, -> { where(state: 'running') }
  scope :failed, -> { where(state: 'failed') }
  scope :expired, -> { where(state: 'expired') }

  ACTIVE_STATES = %w(
    initialized
    provisioning
    running
  )

  INACTIVE_STATES = %w(
    failed
    expired
  )

  RAW_STATES = ACTIVE_STATES + INACTIVE_STATES

  STATES = States.for *RAW_STATES

  state_machine :initial => STATES.initialized do
    STATES.values.each do | s |
      state s
    end

    after_transition \
      :on => :provision,
      :do => :background_provision

    after_transition \
      STATES.provisioning => STATES.running,
      :do => :notify_user_of_success

    after_transition \
      any => STATES.failed,
      :do => :notify_user_of_failure

    after_transition \
      :on => :user_expire,
      :do => :background_expire

    event :provision do
      transition STATES.initialized => STATES.provisioning
    end

    event :finish do
      transition STATES.provisioning => STATES.running
    end

    event :fail_instance do
      transition any => STATES.failed
    end

    event :user_expire do
      transition STATES.running => STATES.expired
    end
  end

  def self.active
    self.in :state => ACTIVE_STATES
  end

  def self.for( i )
    case i
    when self
      i
    else
      find i
    end
  end

  def background_expire
    ExpireWorker.run id
  end

  def background_provision
    ProvisionWorker.run id
  end

  def notify_user_of_expiration
    NotificationWorker.run \
      self.class.name,
      id,
      :instance_expiration
  end

  def notify_user_of_user_expiration
    NotificationWorker.run \
      self.class.name,
      id,
      :instance_user_expiration
  end

  def notify_user_of_failure
    NotificationWorker.run \
      self.class.name,
      id,
      :failed_instance
  end

  def notify_user_of_success
    NotificationWorker.run \
      self.class.name,
      id,
      :new_instance
  end

  def redis?
    service_slug.to_s == 'redis'
  end

  def mongo?
    service_slug.to_s == 'mongo'
  end

  def postgres?
    service_slug.to_s == 'postgres'
  end

  def mysql?
    service_slug.to_s == 'mysql'
  end

  def all?
    service_slug.to_s == 'all'
  end
end
