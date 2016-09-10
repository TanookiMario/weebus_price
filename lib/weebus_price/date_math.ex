defmodule WeebusPrice.DateMath do
  use Timex

  def today do
    DateTime.utc_now |> DateTime.to_date
  end

  def first_day_of_month(%Date{ year: year, month: month }) do
    {:ok, date} = Date.new(year, month, 1)
    date
  end

  def last_day_of_month(date = %Date{ day: day }) do
    Timex.shift(date, days: -day + 1) # first day of month
    |> Timex.shift(months: 1)         # first day of next month
    |> Timex.shift(days: -1)          # last day of previous month
  end

  def all_days_between(first, last, accumulator \\ []) do
    next_day = Timex.shift(first, days: 1)

    if Timex.compare(first, last) > 0 do
      accumulator
    else
      all_days_between(next_day, last, accumulator ++ [first])
    end
  end

  def compare_date(a, b) do
    Timex.compare(a, b) == -1
  end

  def earliest_day(days) do
    days |> Enum.reduce(~D[3000-01-01], fn(a, b) -> lesser_date(a, b) end)
  end

  def latest_day(days) do
    days |> Enum.reduce(~D[2000-01-01], fn(a, b) -> greater_date(a, b) end)
  end

  def lesser_date(a, b) do
    case Timex.compare(a, b) do
      -1 -> a
      0  -> b
      1  -> b
    end
  end

  def greater_date(a, b) do
    case Timex.compare(a, b) do
      -1 -> b
      0  -> b
      1  -> a
    end
  end

  def missing_days_in_month(days) do
    earliest_day = earliest_day(days)
    latest_day   = latest_day(days)
    first_day    = lesser_date(earliest_day, first_day_of_month(earliest_day))
    last_day     = greater_date(latest_day, last_day_of_month(earliest_day))

    all_days_in_month = all_days_between(first_day, last_day)

    Set.difference(MapSet.new(all_days_in_month), MapSet.new(days))
    |> Set.to_list
  end
end
