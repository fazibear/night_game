defmodule NightGame.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      {DynamicSupervisor, name: NightGame.GameSupervisor, strategy: :one_for_one},
      NightGame.Game,
      NightGameWeb.Endpoint
      # Starts a worker by calling: NightGame.Worker.start_link(arg)
      # {NightGame.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NightGame.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NightGameWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
