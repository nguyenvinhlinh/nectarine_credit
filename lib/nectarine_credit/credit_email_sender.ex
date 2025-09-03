defmodule NectarineCredit.CreditEmailSender do
  import Swoosh.Email
  alias NectarineCreditWeb.CreditAssessLive.Form1Schema
  alias NectarineCreditWeb.CreditAssessLive.Form2Schema

  @from_email "admin@nectarinecredit.com"
  @from_fullname "Administrator"

  def send_welcome_email() do
    user = %{
      name: "Nguyen Vinh Linh",
      email: "nguyenvinhlinh93@gmail.com"
    }
    new()
    |> to({user.name, user.email})
    |> from({"Dr B Banner", "hulk.smash@example.com"})
    |> subject("Hello, Avengers!")
    |> html_body("<h1>Hello #{user.name}</h1>")
    |> text_body("Hello #{user.name}\n")
    |> NectarineCredit.Mailer.deliver()
  end

  def credit_granted_email(email, %Form1Schema{}=form_1_schema, %Form2Schema{}=form_2_schema, credit_amount) do
    text_body = create_text_body_for_credit_grant_email(form_1_schema, form_2_schema, credit_amount)
    html_body = create_html_body_for_credit_grant_email(form_1_schema, form_2_schema, credit_amount)
    {:ok, pdf_file_path} = PdfGenerator.generate(html_body, page_size: "A5")
    attachment = Swoosh.Attachment.new(pdf_file_path, filename: "NectarineCredit.pdf")

    new()
    |> to(email)
    |> from({@from_fullname, @from_email})
    |> subject("Nectarine Credit granted you credit!")
    |> text_body(text_body)
    |> attachment(attachment)
  end

  def create_text_body_for_credit_grant_email(%Form1Schema{}=form_1_schema, %Form2Schema{}=form_2_schema, credit_amount) do
    """
    Dear,

    You have been granted #{credit_amount} USD for credit.

    This is question list and your answers:

    1. Do you have a paying job? #{form_1_schema.q_1}
    2. Did you consistently had a paying job for past 12 months? #{form_1_schema.q_2}
    3. Did you own a house? #{form_1_schema.q_3}
    4. Did you own a car? #{form_1_schema.q_4}
    5. Do you have any additional source of income? #{form_1_schema.q_5}
    6. What is your total monthly income from all income source (in USD)? #{form_2_schema.q_1}
    7. What are their total monthly expenses (in USD)? #{form_2_schema.q_2}
    """
  end

  def create_html_body_for_credit_grant_email(%Form1Schema{}=form_1_schema, %Form2Schema{}=form_2_schema, credit_amount) do
    """
    Dear,

    You have been granted #{credit_amount} USD for credit. </br>

    This is question list and your answers: </br>

    1. Do you have a paying job? #{form_1_schema.q_1} </br>
    2. Did you consistently had a paying job for past 12 months? #{form_1_schema.q_2} </br>
    3. Did you own a house? #{form_1_schema.q_3} </br>
    4. Did you own a car? #{form_1_schema.q_4} </br>
    5. Do you have any additional source of income? #{form_1_schema.q_5} </br>
    6. What is your total monthly income from all income source (in USD)? #{form_2_schema.q_1} </br>
    7. What are their total monthly expenses (in USD)? #{form_2_schema.q_2}
    """
  end

  def test() do
    email = "nguyenvinhlinh93@gmail.com"
    form_1_schema = %Form1Schema{
      q_1: true, q_2: true,
      q_3: true, q_4: true,
      q_5: true
    }

    form_2_schema = %Form2Schema{
      q_1: 2000,
      q_2: 500,
    }
    credit_amount = 1000
    credit_granted_email(email, form_1_schema, form_2_schema, credit_amount)
    |> NectarineCredit.Mailer.deliver()
  end
end
