defmodule WeebusPrice.PageView do
  use WeebusPrice.Web, :view
  alias Decimal, as: D

  def currency(amount) do
    D.round(amount, 2)
    |> D.to_string
  end

  def long_date(date = %Date{}) do
    {:ok, formatted} = Timex.format(date, "%B %e, %Y", :strftime)
    formatted
  end
end
