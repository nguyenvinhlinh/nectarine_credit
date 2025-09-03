defmodule NectarineCreditWeb.CreditAssessLive.Form2Schema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :q_1, :integer
    field :q_2, :integer
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:q_1, :q_2])
    |> validate_required([:q_1, :q_2])
    |> validate_number(:q_1, [greater_than: 0])
    |> validate_number(:q_2, [greater_than: 0])
    |> validator_income_greater_than_expense()


  end

  def validator_income_greater_than_expense(changeset) do
    income =  fetch_field!(changeset, :q_1)
    expense = fetch_field!(changeset, :q_2)

    if expense > income do
      add_error(changeset, :q_2, "Expense is greater than income")
    else
      changeset
    end

  end
end
