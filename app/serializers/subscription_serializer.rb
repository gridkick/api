class SubscriptionSerializer < ActiveModel::Serializer
  attributes \
    :id,
    :last_digits,
    :card_type,
    :expiration_date,
    :status,
    :is_active?,
    :name,
    :plan

    def id
      "singleton"
    end
end
