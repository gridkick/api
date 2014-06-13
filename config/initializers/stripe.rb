
type = Rails.env == 'production' ? "LIVE" : "TEST"
Rails.configuration.stripe = {
  :public_key  => ENV["STRIPE_PUBLIC_KEY_#{type}"],
  :secret_key  => ENV["STRIPE_SECRET_KEY_#{type}"]
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]


