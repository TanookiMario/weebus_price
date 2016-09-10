defmodule Mix.Tasks.WeebusPrice.Download do
  use Mix.Task

  alias WeebusPrice.DateMath

  def run([day, filename]) do
    day =
      if day == "today" do
        DateMath.today
      else
        parse_month(day)
      end

    first_day = DateMath.first_day_of_month(day)
    last_day  = DateMath.last_day_of_month(day)

    {:ok, downloader} = WeebusPrice.MintDownloader.start_link

    try do
      result = WeebusPrice.MintDownloader.log_in(
        downloader,
        %{
          username:   System.get_env("MINT_USERNAME"),
          password:   System.get_env("MINT_PASSWORD"),
        }
      )

      case result do
        :ok ->
          IO.puts("Logged in.")
        :need_2fa_code ->
          code = IO.gets("Need 2FA code: ")
          WeebusPrice.MintDownloader.send_2fa_code(downloader, code)
      end

      {:ok, raw_data} = WeebusPrice.MintDownloader.download_csv(
        downloader,
        %{
          start_date: to_date_format(first_day),
          end_date:   to_date_format(last_day)
        }
      )

      if filename do
        File.write!(filename, raw_data)
      end

      Mix.Tasks.WeebusPrice.Calculate.calculate(raw_data)
    after
      WeebusPrice.MintDownloader.stop(downloader)
    end
  end

  def parse_month(string) do
    [month, year] =
      String.split(string, "/")
      |> Enum.map(fn(str) ->
        {int, _} = Integer.parse(str)
        int
      end)

    {:ok, date} = Date.new(year, month, 1)

    date
  end

  def to_date_format(%Date{ year: year, month: month, day: day}) do
    "#{month}/#{day}/#{year}"
  end
end
