FactoryBot.define do
  factory :customer_branch do
    name { "imal Oil Corporation B1" }
    location { "Bhaktapur, Nepal" }

    association :customer
  end
end
