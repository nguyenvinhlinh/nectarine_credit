defmodule NectarineCreditWeb.CreditAssessLive.Form1Schema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :q_1, :boolean
    field :q_2, :boolean
    field :q_3, :boolean
    field :q_4, :boolean
    field :q_5, :boolean
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:q_1, :q_2, :q_3, :q_4, :q_5])
    |> validate_required([:q_1, :q_2, :q_3, :q_4, :q_5])
  end

  def calculate_score(%__MODULE__{}=form_1_schema) do
    score_map = %{
      q_1: 4,
      q_2: 2,
      q_3: 2,
      q_4: 1,
      q_5: 2
    }

    field_list = [:q_1, :q_2, :q_3, :q_4, :q_5]
    Enum.reduce(field_list, 0, fn(field, a) ->
      if Map.get(form_1_schema, field) == true do
        a + Map.get(score_map, field)
      else
        a
      end
    end)
  end
end
