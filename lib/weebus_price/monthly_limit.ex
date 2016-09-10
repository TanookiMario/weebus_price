defmodule WeebusPrice.MonthlyLimit do
  alias WeebusPrice.DateMath

  def calculate(daily_spend_by_person, options \\ Application.fetch_env!(:weebus_price, :accounts)) do
    for {person, spending_by_day} <- daily_spend_by_person, into: %{} do
      days =
        pad_missing_days(spending_by_day)
        |> monthly_limit(options[:people][person][:monthly_limit])

      {person, days}
    end
  end

  def monthly_limit(spending_by_day, limit) do
    sorted_days =
      spending_by_day
      |> Map.keys
      |> Enum.sort(&DateMath.compare_date/2)

    days_in_month = length(sorted_days)

    initial = %{
      days_left:            days_in_month,
      total_spent:          0,
      total_left:           limit,
      average_to_meet_goal: limit / days_in_month
    }

    Enum.reduce(sorted_days, %{ current: initial, days: %{}} , fn(day, %{ current: tally, days: days}) ->
      days_left    = length(sorted_days) - Enum.find_index(sorted_days, &(&1 == day))
      spent_so_far = tally[:total_spent] + spending_by_day[day][:total]
      total_left   = limit - spent_so_far

      as_of_this_day = %{
        days_left:            days_left,
        total_spent:          spent_so_far,
        total_left:           limit - spent_so_far,
        average_to_meet_goal: case days_left do
                                0 -> 0
                                _ -> total_left / days_left
                              end
      }

      %{ current: as_of_this_day, days: Map.merge(days, %{day => as_of_this_day})}
    end)[:days]
  end

  def pad_missing_days(spending_by_day) do
    missing_days =
      spending_by_day
      |> Map.keys
      |> DateMath.missing_days_in_month

    padded_days = for day <- missing_days, into: %{} do
      { day, %{total: 0, transactions: []} }
    end

    Map.merge(spending_by_day, padded_days)
  end
end
