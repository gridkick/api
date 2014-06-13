class UserSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :created_at, :active_instances, :max_instances, :updated_at, :auth_token, :email, :has_subscription, :has_active_subscription, :promo_code, :promo_description

  def has_subscription
    object.subscription.present? or object.subscription_override?
  end

  def has_active_subscription
    object.subscription_override? or (has_subscription and object.subscription.is_active?)
  end

  def active_instances
    object.instances.where_active.count
  end
end
