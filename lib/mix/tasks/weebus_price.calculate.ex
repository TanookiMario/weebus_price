defmodule Mix.Tasks.WeebusPrice.Calculate do
  use Mix.Task

  alias WeebusPrice.DateMath

  def run(args) do
    {options, _, _} = OptionParser.parse(args)

    raw_data = File.read!(options[:filename])

    calculate(raw_data)
  end

  def calculate(raw_data) do
    limit_by_day =
      WeebusPrice.TransactionParser.from_csv(raw_data)
      |> WeebusPrice.DailySpendByPerson.calculate
      |> WeebusPrice.MonthlyLimit.calculate

    todays_data = for {person, limit} <- limit_by_day, into: %{} do
      {person, limit[DateMath.today]}
    end

    IO.inspect(todays_data)
  end
end
