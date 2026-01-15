defmodule ForthIbE.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [ ForthIbE.REPL
    ]

    opts = [strategy: :one_for_one, name: Manager]
    Supervisor.start_link(children, strategy: :one_for_one)

  end
end
