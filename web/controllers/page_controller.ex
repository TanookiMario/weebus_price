defmodule WeebusPrice.PageController do
  use WeebusPrice.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
