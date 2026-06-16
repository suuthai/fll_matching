module HomeHelper
  TICKET_PLANS = {
    "only_one" => {
      label: "レッスンチケット1回分を購入する",
      price: 2000,
      tickets_count: 1
    },

    "three_bundle" => {
      label: "レッスンチケット3回分をまとめて購入する(1000円お得!)",
      price: 5000,
      tickets_count: 3
    },

    "five_bundle" => {
      label: "レッスンチケット5回分をまとめて購入する(2500円お得!)",
      price: 7500,
      tickets_count: 5
    }
  }.freeze

  def ticket_plans
    TICKET_PLANS
  end
end