defmodule WeebusPrice.PageView do
  use WeebusPrice.Web, :view
  alias Decimal, as: D

  def daily_amount(day_data, person) do
    D.round(day_data[person][:average_to_meet_goal], 2)
  end

  def long_date(date = %Date{}) do
    {:ok, formatted} = Timex.format(date, "%B %e, %Y", :strftime)
    formatted
  end
end
