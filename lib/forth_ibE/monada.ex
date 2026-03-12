defmodule ForthIbE.Monada do
  use GenServer

  use ForthIbE.Impl.Common
  #use ForthIbE.Impl.Monada
  @generator ForthIbE.Monada
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

  def get_var(eng_name, var_name) do
    GenServer.call(eng_name, {:get_var, String.downcase(var_name)})
  end

  def add_var(eng_name, var_name, value) do
    GenServer.cast(eng_name, {:add_var, String.downcase(var_name), value})
  end
end
