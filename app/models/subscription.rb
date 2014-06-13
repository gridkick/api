class Subscription
  include App::Document

  belongs_to :user

  field \
    :customer_id,
    :type => String

  field \
    :last_digits,
    :type => String

  field \
    :card_type,
    :type => String

  field \
    :expiration_date,
    :type => String

  field \
    :status,
    :type => String

  field \
    :name,
    :type => String

  field \
    :plan,
    :type => String

  validates_presence_of \
    :customer_id

  attr_accessor :stripe_token, :coupon

  after_save :update_max_instances

  def update_max_instances
    user.max_instances = plan.to_i
    user.save!
  end

  def update_stripe
    if customer_id.nil?
      cust_info = { :email => user.email,
                    :card => stripe_token,
                    :plan => plan }
      cust_info.merge!(:coupon => coupon) if coupon.present?
      customer = Stripe::Customer.create(cust_info)
    else
      customer = Stripe::Customer.retrieve({:id => customer_id, :expand => ['default_card']})
      customer.card = stripe_token
      customer.email = user.email
      customer.save
    end
    default_card = customer.cards.data.detect{|obj| obj[:id] == customer.default_card}
    self.card_type       = default_card.type
    self.customer_id     = customer.id
    self.expiration_date = "#{default_card.exp_month}/#{default_card.exp_year}"
    self.last_digits     = default_card.last4
    self.name            = default_card.name
    self.status          = customer.try(:subscription).try(:status)
    self.stripe_token    = nil
    save!
  rescue Stripe::StripeError => e
    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, "#{e.message}"
    false
  end

  def update_stripe_plan
    return false if not can_change_plan?
    customer = Stripe::Customer.retrieve({:id => customer_id, :expand => ['default_card']})
    customer.email = user.email
    customer.plan  = plan
    customer.save
    self.status    = customer.try(:subscription).try(:status)
    self.plan      = plan
    save!
  rescue Stripe::StripeError => e
    logger.error "Stripe error while updating customer plan: #{e.message}"
    errors.add :base, "#{e.message}"
    false
  end

  def cancel
    customer = Stripe::Customer.retrieve({:id => customer_id})
    customer.cancel_subscription
    self.status = customer.try(:subscription).try(:status)
    self.plan = "0"
    save!
  rescue Stripe::StripeError => e
    logger.error "Stripe error while canceling subscription: #{e.message}"
    errors.add :base, "#{e.message}"
    false
  end

  def is_active?
    ["active", "trialing"].include?(status)
  end

  def can_change_plan?
    user.instances.where_active.count <= plan.to_i
  end
end
