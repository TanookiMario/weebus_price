defmodule WeebusPrice.DailySpendByPerson do
  alias WeebusPrice.Transaction
  alias Decimal, as: D

  def calculate(transactions, options \\ Application.fetch_env!(:weebus_price, :accounts)) do
    transactions
    |> filter(options[:categories], options[:ignored_labels])
    |> group_by_people(options[:people])
    |> group_by_day
  end

  def filter(transactions, categories \\ [], ignored_labels \\ []) do
    transactions
    |> Enum.filter(fn(%Transaction{ category: category }) ->
      Enum.member?(categories, category)
    end)
    |> Enum.reject(fn(%Transaction{ labels: labels }) ->
      Enum.member?(ignored_labels, labels)
    end)
  end

  def group_by_people(transactions, people) do
    transactions
    |> Enum.group_by(fn(%Transaction{ account: account }) ->
      matching_people =
        Enum.filter(people, fn({_person, data}) ->
          Enum.member?(data[:accounts], account)
        end)
        |> Enum.map(fn({person, _data}) -> person end)

      List.first(matching_people) || :none
    end)
  end

  def group_by_day(people_with_transactions) do
    for {person, transactions} <- people_with_transactions, into: %{} do
      grouped = Enum.group_by(transactions, fn(%Transaction{ date: date }) ->
        date
      end)

      days = for {day, transactions} <- grouped, into: %{} do
        { day, to_daily_summary(transactions) }
      end

      {person, days}
    end
  end

  def to_daily_summary(transactions) do
    total =
    for %Transaction{ amount: amount, type: type } <- transactions do
        case type do
          "debit" -> D.new(amount)
          "credit" -> D.minus(D.new(amount))
        end
      end
      |> Enum.reduce(D.new(0), &D.add/2)

    %{ total: total, transactions: transactions}
  end
end
