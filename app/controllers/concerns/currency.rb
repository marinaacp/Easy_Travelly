require 'money'

module Currency
  def currency_conversion
    Money.default_bank = Money::Bank::VariableExchange.new(Money::RatesStore::Memory.new)
    Money.add_rate("USD", "EUR", 1.0036163)
    Money.add_rate("EUR", "USD", 0.803115)
  end
end
