defmodule ForthIbE.Monad do
  use GenServer

  require Logger

  use ForthIbE.Impl.Common

  @generator ForthIbE.Monad
#--- Impl ---

#--- API ----
  def start(params) do
    {name, _stocks} = params
	IO.puts("Старт движок интерпретатора Forth_ibE #{name}")
	GenServer.start_link(@generator, params)
  end

  def execute(eng_name, words) do
    GenServer.cast(eng_name, {:execute, words})
  end

  def add_var(eng_name, var_name, value) do
    GenServer.cast(eng_name, {:add_var, var_name, value})
  end

  def get_var(eng_name, var_name) do
    GenServer.call(eng_name, {:get_var, var_name})
  end

  def get_stocks(eng_name) do
    GenServer.call(eng_name, :get_stocks)
  end
end
