defmodule NectarineCreditWeb.CreditAssessLive.Index do
  use NectarineCreditWeb, :live_view
  alias NectarineCreditWeb.CreditAssessLive.Form1Schema
  alias NectarineCreditWeb.CreditAssessLive.Form2Schema
  alias NectarineCreditWeb.CreditAssessLive.Form3Schema
  alias NectarineCredit.CreditEmailSender
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

    socket
    |> assign(:form_1, form_1)
    |> assign(:form_1_is_submitted, false)
    |> assign(:total_score, -1)
  end

  def handle_live_action(socket, :scene_2, _params) do
    # check if scence 1 form did not submit, force to redirect
    form_2_schema = %Form2Schema{}
    form_2 = form_2_schema
    |> Form2Schema.changeset(%{})
    |> to_form

    socket
    |> assign(:form_2, form_2)
    |> assign(:form_2_is_submitted, false)
    |> assign(:credit_amount, 0)
  end

  def handle_live_action(socket, :scene_3, _params) do
    IO.inspect "DEBUG #{__ENV__.file} @#{__ENV__.line}"
    IO.inspect socket.assigns
    IO.inspect "END"

    # dev only
    credit_amount = socket.assigns[:credit_amount]
    # check if scence 2 form did not submit, force to redirect
    form_3 = %Form3Schema{}
    |> Form3Schema.changeset(%{})
    |> to_form()

    socket
    |> assign(:form_3, form_3)
    |> assign(:credit_amount, credit_amount)
  end

  @impl true
  def handle_event("submit_form_1", %{"form1_schema" => form1_params}, socket) do
    form_1_changeset = %Form1Schema{}
    |> Form1Schema.changeset(form1_params)

    with true <- is_changeset_valid?(form_1_changeset),
         form_1_schema <- Ecto.Changeset.apply_action!(form_1_changeset, :update),
         {:ok, :greater_than_6, total_score} <- is_score_greater_than_6(form_1_schema) do
      socket_mod = socket
      |> assign(:form_1_schema, form_1_schema)
      |> assign(:form_1_is_submitted, true)
      |> assign(:total_score, total_score)
      |> push_patch(to: ~p"/credit_assess/scene_2")
      |> assign(:form_1, nil) # Free memory

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

  @impl true
  def handle_event("validate_form_2", %{"form2_schema" => form2_schema_params}, socket) do
    form_2 = Form2Schema.changeset(%Form2Schema{}, form2_schema_params)
    |> to_form(action: :validate)
    socket_mod = socket
    |> assign(:form_2, form_2)
    {:noreply, socket_mod}
  end

  @impl true
  def handle_event("submit_form_2", %{"form2_schema" => form2_schema_params}, socket) do
    form_2_changeset = Form2Schema.changeset(%Form2Schema{}, form2_schema_params)
    with true <- is_changeset_valid?(form_2_changeset),
         form_2_schema <- Ecto.Changeset.apply_action!(form_2_changeset, :update),
           credit_amount <- calculate_credit_amount(form_2_schema) do

      socket_mod = socket
      |> assign(:form_2_schema, form_2_schema)
      |> assign(:credit_amount, credit_amount)
      |> assign(:form_2_is_submitted, true)
      |> push_patch(to: ~p"/credit_assess/scene_3")
      |> assign(:form_2, nil) # Free memory
      {:noreply, socket_mod}
    else
      {:error, :changeset_invalid, changeset} ->
        form_2 = to_form(changeset, action: :validate)
        socket_mod = socket
        |> assign(:form_2, form_2)
        |> put_flash(:error, "Fix error(s) before submit")
        {:noreply, socket_mod}

    end
  end

  @impl true
  def handle_event("validate_form_3", %{"form3_schema" => form3_schema_params}, socket) do
    form_3 = Form3Schema.changeset(%Form3Schema{}, form3_schema_params)
    |> to_form(action: :validate)

    socket_mod = socket
    |> assign(:form_3, form_3)
    {:noreply, socket_mod}
  end

  @impl true
  def handle_event("submit_form_3", %{"form3_schema" => form3_schema_params}, socket) do
    form_3_schema = %Form3Schema{}
    |> Form3Schema.changeset(form3_schema_params)
    |> Ecto.Changeset.apply_action!(:update)

    email = form_3_schema.email
    form_1_schema = socket.assigns[:form_1_schema]
    form_2_schema = socket.assigns[:form_2_schema]
    credit_amount = socket.assigns[:credit_amount]

    CreditEmailSender.credit_granted_email(email, form_1_schema, form_2_schema, credit_amount)
    |> NectarineCredit.Mailer.deliver()

    # Redirect to scene 1
    socket_mod = socket
    |> put_flash(:info, "Sending email to #{email}")
    |> push_navigate(to: ~p"/credit_assess/scene_1")
    |> assign(:form_3, nil) #Free memory

    {:noreply, socket_mod}
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

  def calculate_credit_amount(form_2_schema) do
    (form_2_schema.q_1 - form_2_schema.q_2) * 12
  end
end
