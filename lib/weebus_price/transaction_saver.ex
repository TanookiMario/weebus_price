defmodule WeebusPrice.TransactionSaver do
  alias WeebusPrice.Transaction
  alias WeebusPrice.DateMath
  alias WeebusPrice.Repo
  alias Ecto.Multi

  def save_month(transactions, day_in_month = %Date{}) do
    first_day = DateMath.first_day_of_month(day_in_month)
    last_day  = DateMath.last_day_of_month(day_in_month)

    {:ok, _} =
      Multi.new
      |> Multi.delete_all(:deleted, Transaction.in_date_range(first_day, last_day))
      |> Multi.insert_all(:inserted, Transaction, transactions |> Enum.map(&sanitize_model/1))
      |> Repo.transaction

    transactions
  end

  defp sanitize_model(model) do
    model
    |> Map.from_struct
    |> Map.drop([:__meta__, :__struct__, :id])
    |> Map.update!(:date, fn(date = %Date{}) ->
      date
    end)
    |> Map.update!(:inserted_at, fn(_) ->
      Ecto.DateTime.utc
    end)
    |> Map.update!(:updated_at, fn(_) ->
      Ecto.DateTime.utc
    end)
  end
end
