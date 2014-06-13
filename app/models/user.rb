class User
  include App::Document
  before_save :ensure_authentication_token

  devise :database_authenticatable, :recoverable,
         :rememberable, :trackable, :validatable, :token_authenticatable

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Token authenticatable
  field :authentication_token, :type => String

  field \
    :registered_at,
    :type => Time

  field \
    :accepted_terms, :type => Boolean

  field \
    :subscription_override, :type => Boolean, :default => false

  field \
    :promo_code, :type => String

  field \
    :promo_description, :type => String

  validates_inclusion_of :accepted_terms, in: [true]

  DEFAULT_MAX_INSTANCES = 0
  field \
    :max_instances,
    :default => proc { ::User::DEFAULT_MAX_INSTANCES },
    :type => Integer

  has_many :instances do
    def in_state( state )
      state = state.to_s
      case state
      when 'active'
        where_active
      when 'inactive'
        where_inactive
      else
        # explicitly reference `self` here since `in` is a keyword
        self.in :state => state
      end
    end

    def where_active
      # explicitly reference `self` here since `in` is a keyword
      self.in :state => ::Instance::ACTIVE_STATES
    end

    def where_inactive
      # explicitly reference `self` here since `in` is a keyword
      self.in :state => ::Instance::INACTIVE_STATES
    end
  end

  has_many :service_requests

  has_one \
    :iam_user,
    :class_name => 'IAMUser'

  has_one :subscription

  # alias the devise name to output more friendly name via serializer
  alias_attribute :auth_token , :authentication_token

  # for backwards compatibility after introducing devise
  alias_attribute :api_key , :authentication_token

  def self.[]( email )
    find_by :email => email
  end

  def background_create_aws_data
    CreateUserAwsDataWorker.run id
  end

  def background_notify_admin_of_creation
    NotificationWorker.run \
      self.class.name,
      id,
      :admin_new_user
  end

  def has_prepared_iam_user?
    ( iam_user or build_iam_user ).prepared?
  end

  ## max_instances
  #
  # If max_instances is falsy, return the default
  #
  alias_method :__max_instances__ , :max_instances
  def max_instances
    __max_instances__ or DEFAULT_MAX_INSTANCES
  end

  def max_instances_reached?
    instances.where_active.count >= max_instances
  end
end
