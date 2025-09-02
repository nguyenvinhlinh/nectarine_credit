defmodule NectarineCreditWeb.PageController do
  use NectarineCreditWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
