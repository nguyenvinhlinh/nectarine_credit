defmodule NectarineCreditWeb.CreditAssessLive.Index do
  use NectarineCreditWeb, :live_view
  alias NectarineCreditWeb.CreditAssessLive.Form1Schema
  embed_templates "index_html/*"

  @impl true
  def mount(params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, uri, socket) do
    socket_mod = handle_live_action(socket, socket.assigns.live_action, params)
    {:noreply, socket_mod}
  end

  def handle_live_action(socket, :index, _params) do
    socket
    |> put_flash(:info, "Patch to /credit_assess/scene_1")
    |> push_patch(to: ~p"/credit_assess/scene_1")
  end

  def handle_live_action(socket, :scene_1, _params) do
    form_1_schema = %Form1Schema{}
    form_1 = form_1_schema
    |> Form1Schema.changeset(%{})
    |> to_form()

    socket_mod = socket
    |> assign(:form_1, form_1)
    |> assign(:form_1_is_submitted, false)
    |> assign(:total_score, -1)
  end

  def handle_live_action(socket, :scene_2, _params) do
    # check if scence 1 form did not submit, force to redirect
    socket
  end


  @impl true
  def handle_event("validate_form_1", params, socket) do
    {:noreply, socket}
  end
  @impl true

  def handle_event("submit_form_1", %{"form1_schema" => form1_params}, socket) do
    form_1_changeset = %Form1Schema{}
    |> Form1Schema.changeset(form1_params)

    with true <- form_1_changeset.valid?,
         form_1_schema <- Ecto.Changeset.apply_action!(form_1_changeset, :update),
         {:ok, :greater_than_6, total_score} <- is_score_greater_than_6(form_1_schema) do
      socket_mod = socket
      |> assign(:form_1_schema, form_1_schema)
      |> assign(:form_1_is_submitted, true)
      |> push_patch(to: ~p"/credit_assess/scene_2")

      {:noreply, socket_mod}
    else
      {:error, :changeset_invalid, changeset} ->
        form_1 = to_form(changeset, action: :validate)
        socket_mod = socket
        |> assign(:form_1, form_1)
        |> put_flash(:error, "Please fix error(s) before submit")

        {:noreply, socket_mod}
      {:error, :not_greater_than_6, form_1_schema, total_score} ->
        socket_mod = socket
        |> assign(:form_1_schema, form_1_schema)
        |> assign(:form_1_is_submitted, true)
        |> assign(:total_score, total_score)
        {:noreply, socket_mod}
    end
  end

  def get_checked_value(field, radio_value) do
    if field.value in [true, "true"] and radio_value in [true, "true"], do: "true", else: "false"
  end


  def is_changeset_valid?(changeset) do
    if changeset.valid?, do: true, else: {:error, :changeset_invalid, changeset}
  end

  def is_score_greater_than_6(form_1_schema) do
    total_score = Form1Schema.calculate_score(form_1_schema)
    if total_score > 6, do: {:ok, :greater_than_6, total_score}, else: {:error, :not_greater_than_6, form_1_schema, total_score}
  end

end
