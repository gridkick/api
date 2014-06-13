class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!

  def index
    render :json => current_user.subscription, :root => "subscriptions"
  end

  def create
    @subscription = ( current_user.subscription or current_user.build_subscription )

    # Get the credit card details submitted by the form
    @subscription.stripe_token = subscription_create_params[:stripe_token]
    if subscription_create_params[:plan]
      @subscription.plan = subscription_create_params[:plan]
    end

    if subscription_create_params[:coupon]
      @subscription.coupon = subscription_create_params[:coupon]
    end

    if @subscription.update_stripe
      render :json => current_user.subscription, :status => :accepted
    else
      render :json => {error: "There was an error with your credit card" }, :status => :payment_required
    end
  end

  def show
    render :json => current_user.subscription, :status => :accepted
  end

  def destroy
    if current_user.subscription.cancel
      instances = current_user.instances.in_state 'active'
      instances.each do |instance|
        instance.user_expire
      end
      render :json => current_user.subscription, :status => :accepted
    else
      render :json => {error: "There was an error canceling your subscription" }, :status => :unprocessable_entity
    end
  end

  def update
    @subscription = current_user.subscription
    @subscription.plan = subscription_update_params[:plan]

    if @subscription.update_stripe_plan
      render :json => current_user.subscription, :status => :accepted
    else
      render :json => {error: "There was an error updating your plan" }, :status => :unprocessable_entity
    end

  end

  protected

  def subscription_create_params
    params.require( :subscription ).permit :stripe_token, :plan, :coupon
  end

  def subscription_update_params
    params.require( :subscription ).permit :plan
  end
end