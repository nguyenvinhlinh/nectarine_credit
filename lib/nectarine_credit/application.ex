defmodule NectarineCredit.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NectarineCreditWeb.Telemetry,
      # NectarineCredit.Repo,
      {DNSCluster, query: Application.get_env(:nectarine_credit, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: NectarineCredit.PubSub},
      # Start a worker by calling: NectarineCredit.Worker.start_link(arg)
      # {NectarineCredit.Worker, arg},
      # Start to serve requests, typically the last entry
      NectarineCreditWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NectarineCredit.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NectarineCreditWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
