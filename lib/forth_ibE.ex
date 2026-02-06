defmodule ForthIbE do
  @moduledoc """
  Documentation for `ForthIbE`.
  """
  @server ForthIbE.Server

  def start(params) do
	IO.puts("Старт менеджера интерпретатора Forth_ibE")
	GenServer.start_link(@server, params)
  end

  def execute(eng_name, words) do
    GenServer.call(eng_name, {:execute, words})
  end

  def get_var(eng_name, var_name) do
    GenServer.call(eng_name, {:get_var, var_name})
  end

  def add_var(eng_name, var_name, value) do
    GenServer.cast(eng_name, {:add_var, var_name, value})
  end

end
