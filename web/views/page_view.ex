defmodule WeebusPrice.PageView do
  use WeebusPrice.Web, :view
  alias Decimal, as: D

  def daily_amount(day_data, person) do
    D.round(day_data[person][:average_to_meet_goal], 2)
  end
end
