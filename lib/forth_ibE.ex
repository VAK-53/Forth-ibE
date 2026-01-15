defmodule ForthIbE do
  @moduledoc """
  Documentation for `ForthIbE`.
  """
  use GenServer
  import ForthIbE.Compouser

  def start_link(_) do
	IO.puts("Старт менеджера интерпретатора Forth_ibE")
	GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
	{:ok, dictionary} = ForthIbE.Dictionary.init()
    {:ok, _lex_table, dictionary} = compouse(dictionary) # непонятно, зачем _lex_table?
	stack = []
	return_stack = []
	state = {stack, return_stack, dictionary}
	IO.inspect(self())
	ForthIbE.CLI.start_link(state)
	{:ok, state}
  end

  def child_spec(opts) do
    %{
		id: __MODULE__,
		start: {__MODULE__, :start_link, [nil]},
		type: :worker,
		restart: :permanent,
		shutdown: 500
  	}
  end
end
