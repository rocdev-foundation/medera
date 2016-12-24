defmodule Medera.PageController do
  use Medera.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
