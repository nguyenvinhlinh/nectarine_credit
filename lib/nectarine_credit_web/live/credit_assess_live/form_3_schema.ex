defmodule NectarineCreditWeb.CreditAssessLive.Form3Schema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :email, :string
  end

  def changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
  end
end
