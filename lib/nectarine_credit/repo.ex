defmodule NectarineCredit.Repo do
  use Ecto.Repo,
    otp_app: :nectarine_credit,
    adapter: Ecto.Adapters.Postgres
end
