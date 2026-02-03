defmodule ForthIbE.Server do
  @moduledoc """
  Documentation for `ForthIbE`.
  """
  use GenServer
  import ForthIbE.Compouser
  import ForthIbE.Interpreter
  import ForthIbE.Engin			# run
  import ForthIbE.Tokenizer		# parse
  import ForthIbE.Dictionary


  def start_link(name) do
	IO.puts("Старт сервера интерпретатора Forth_ibE")
    #eng_name = String.to_atom(name)
	GenServer.start_link(__MODULE__, nil, name: name)
  end

  @impl GenServer
  def init(_) do
	{:ok, dictionary} = ForthIbE.Dictionary.init()
    {:ok, _lex_table, dictionary} = compouse(dictionary) # непонятно, зачем _lex_table?
	stack = []
	return_stack = []
	state = {stack, return_stack, dictionary}
	{:ok, state}
  end

  @impl true
  def handle_call({:execute, words},  _from,  {_stack, _return_stack, dictionary} = state) do
    result = words |> evaluate(state)
    case result do
      {:ok, stack, return_stack, dictionary} -> {:reply, {:ok, stack}, {stack, return_stack, dictionary}}
      {:error, reason} -> {:reply, {:error, reason}, {[], [], dictionary}}
    end
  end

  @impl true
  def handle_call({:get_var, name},  _from,  {stack, return_stack, dictionary} = _state) do
    result = get_var(dictionary, name)
    case result do
      :error -> {:reply, {:error, "не существует"}, {stack, return_stack, dictionary}}
      value -> {:reply, {:ok, value}, {stack, return_stack, dictionary}}
    end
  end

  @impl true
  def handle_cast({:add_var, name, value},  {stack, return_stack, dictionary}) do
    dictionary = add_var(dictionary, name, value)
    {:noreply, {stack, return_stack, dictionary}}
  end

  # _________________implementation ___________________

  defp evaluate(words, state) do
    {stack, return_stack, dictionary} = state
    {virt_code, dictionary} = words |> parse |> interpret(dictionary) 
    run(virt_code, stack, return_stack, dictionary)
  end

end
