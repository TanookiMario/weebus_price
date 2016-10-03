defmodule WeebusPrice.MonthlyLimit do
  alias WeebusPrice.DateMath
  alias Decimal, as: D

  def calculate(daily_spend_by_person, options \\ Application.fetch_env!(:weebus_price, :accounts)) do
    for {person, spending_by_day} <- daily_spend_by_person, into: %{} do
      days =
        pad_missing_days(spending_by_day)
        |> monthly_limit(D.new(options[:people][person][:monthly_limit]))

      {person, days}
    end
  end

  def monthly_limit(spending_by_day, goal) do
    sorted_days =
      spending_by_day
      |> Map.keys
      |> Enum.sort(&DateMath.compare_date/2)

    days_in_month = length(sorted_days)

    initial = %{
      goal:                 goal,
      days_left:            days_in_month,
      total_spent:          D.new(0),
      total_left:           goal,
      average_spent_so_far: D.new(0),
      average_to_meet_goal: D.div(goal, D.new(days_in_month))
    }

    Enum.reduce(sorted_days, %{ current: initial, days: %{}} , fn(day, %{ current: tally, days: days}) ->
      days_so_far  = Enum.find_index(sorted_days, &(&1 == day))
      days_left    = length(sorted_days) - days_so_far
      spent_so_far = D.add(D.new(tally[:total_spent]), D.new(spending_by_day[day][:total]))
      total_left   = D.sub(goal, spent_so_far)

      as_of_this_day = %{
        goal:                 goal,
        days_left:            days_left,
        total_spent:          spent_so_far,
        total_left:           D.sub(goal, spent_so_far),
        average_spent_so_far: D.div(spent_so_far, D.new(days_so_far + 1)),
        average_to_meet_goal: case days_left do
                                0 -> D.new(0)
                                _ -> D.div(total_left, D.new(days_left))
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
