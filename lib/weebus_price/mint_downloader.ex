defmodule WeebusPrice.MintDownloader do
  use Hound.Helpers

  use GenServer

  # Client

  def start_link do
    GenServer.start_link(__MODULE__, %{ state: :logged_out })
  end

  def log_in(pid, credentials) do
    GenServer.call(pid, {:log_in, credentials}, 35_000)
  end

  def send_2fa_code(pid, code) do
    GenServer.call(pid, {:send_2fa_code, code}, 20_000)
  end

  def download_csv(pid, options) do
    GenServer.call(pid, {:download, options}, 20_000)
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  # Server

  def init(state) do
    Application.ensure_all_started(:hound)
    Hound.start_session

    {:ok, state}
  end

  def terminate(_reason, _state) do
    Hound.end_session
  end

  def handle_call({:log_in, credentials}, _from, state) do
    case log_in(credentials) do
      :ok ->
        {:reply, :ok, %{state | state: :logged_in }}
      :need_2fa_code ->
        {:reply, :need_2fa_code, %{state | state: :need_code }}
    end
  end

  def handle_call({:send_2fa_code, code}, _from, state) do
    set_2fa_code(code)
    {:reply, :ok, %{ state | state: :logged_in}}
  end

  def handle_call({:download, options}, _from, state) do
    transactions = fetch_raw_transaction_data(cookies, options)
    {:reply, {:ok, transactions}, state}
  end

  def log_in(creds) do
    navigate_to "https://www.mint.com"
    click {:link_text, "Log In"}

    fill_field({:id, "ius-userid"},   creds[:username])
    fill_field({:id, "ius-password"}, creds[:password])

    click {:id, "ius-sign-in-submit-btn"}

    :timer.sleep(5000)

    case search_element(:id, "ius-mfa-options-submit-btn") do
      {:ok, _element} ->
        click {:id, "ius-mfa-options-submit-btn"}
        :timer.sleep(5000)
        :need_2fa_code
      {:error, _error} ->
        :ok
    end
  end

  def set_2fa_code(code) do
    fill_field({:id, "ius-mfa-confirm-code"}, code)
    click {:id, "ius-mfa-otp-submit-btn"}

    :timer.sleep(5000)

    :ok
  end

  def fetch_raw_transaction_data(cookies, filters) do
    HTTPoison.get!(
      build_url(filters),
      %{},
      timeout: 15_000,
      recv_timeout: 15_000,
      hackney: [cookie: convert_cookies_to_hackney(cookies)]
    ).body
  end

  def build_url(filters) do
    "https://mint.intuit.com/transactionDownload.event?startDate=#{filters[:start_date]}&endDate=#{filters[:end_date]}&queryNew=&offset=0&exclHidden=T&filterType=cash&comparableType=8"
  end

  def convert_cookies_to_hackney(hound_cookies) do
    Enum.map(hound_cookies, fn(cookie) ->
      "#{cookie["name"]}=#{cookie["value"]}"
    end)
    |> Enum.join("; ")
  end
end
