defmodule ForthIbE do
  @moduledoc """
  Documentation for `ForthIbE`.
  """
  @server ForthIbE.Server

  def start_link(_) do
	IO.puts("Старт менеджера интерпретатора Forth_ibE")
	GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def execute(words) do
    GenServer.call(@server, {:execute, words})
  end

  def get_var(name) do
    GenServer.call(@server, {:get_var, name})
  end

  def add_var(name, value) do
    GenServer.cast(@server, {:add_var, name, value})
  end

end
