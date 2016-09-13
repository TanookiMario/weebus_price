defmodule WeebusPrice.PageController do
  use WeebusPrice.Web, :controller

  alias WeebusPrice.DateMath
  alias WeebusPrice.Transaction

  def index(conn, _params) do
    day       = DateMath.today
    first_day = DateMath.first_day_of_month(day)
    last_day  = DateMath.last_day_of_month(day)

    limit_by_day =
      Transaction.in_date_range(first_day, last_day)
      |> Repo.all
      |> WeebusPrice.DailySpendByPerson.calculate
      |> WeebusPrice.MonthlyLimit.calculate

    todays_data = for {person, limit} <- limit_by_day, into: %{} do
      {person, limit[DateMath.today]}
    end

    conn
    |> assign(:todays_data, todays_data)
    |> render("index.html")
  end
end
