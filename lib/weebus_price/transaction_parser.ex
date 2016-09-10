defmodule WeebusPrice.TransactionParser do
  alias WeebusPrice.Transaction

  def from_csv(raw_data) when is_binary(raw_data) do
    raw_data
    |> String.split("\n")
    |> Enum.reject(&(String.length(&1) == 0))
    |> CSV.decode
    |> Enum.to_list
    |> from_csv
  end

  def from_csv(rows) when is_list(rows) do
    [ _header | rows ] = rows

    rows
    |> Enum.map(&from_csv_row/1)
  end

  def from_csv_row(row) do
    %Transaction{
      date:                 Enum.at(row,0) |> parse_date,
      description:          Enum.at(row,1),
      original_description: Enum.at(row,2),
      amount:               Enum.at(row,3) |> parse_currency,
      type:                 Enum.at(row,4),
      category:             Enum.at(row,5),
      account:              Enum.at(row,6),
      labels:               Enum.at(row,7),
      notes:                Enum.at(row,8)
    }
  end

  def parse_date(raw_date) do
    [month, day, year] =
      raw_date
      |> String.split("/")
      |> Enum.map(fn(str) ->
        case Integer.parse(str) do
          {int, _} -> int
          :error   -> raise "Invalid date: #{raw_date}"
        end
      end)

    {:ok, date} = Date.new(year, month, day)

    date
  end

  def parse_currency(raw_amount) do
    case Float.parse(raw_amount) do
      {float, _} -> float
      :error   -> raise "Invalid amount: #{raw_amount}"
    end
  end
end
