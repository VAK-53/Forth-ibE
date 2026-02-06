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


  @impl GenServer
  def init({name, recipients}) do
	{:ok, dictionary} = ForthIbE.Dictionary.init()
    {:ok, _lex_table, dictionary} = compouse(dictionary) # непонятно, зачем _lex_table?
	stack = []
	return_stack = []

    atom_name = String.to_atom(name)
    Process.register(self(), atom_name)
	state = {stack, return_stack, dictionary, recipients}
	{:ok, state}
  end

  @impl true
  def handle_call({:get_var, name},  _from,  {stack, return_stack, dictionary, recipients} = _state) do
    result = get_var(dictionary, name)
    case result do
      :error -> {:reply, {:error, "не существует"}, {stack, return_stack, dictionary, recipients}}
      value -> {:reply, {:ok, value}, {stack, return_stack, dictionary, recipients}}
    end
  end

  @impl true
  def handle_cast({:execute, words}, {_stack, _return_stack, dictionary, recipients} = state) do
    result = words |> evaluate(state)
    case result do
      {:ok, stack, return_stack, dictionary, recipients} -> {:noreply, {stack, return_stack, dictionary, recipients}}
      {:error, reason} -> {:noreply, {[], [], dictionary, recipients}} # добавить журналирование
    end
  end

  @impl true
  def handle_cast({:add_var, name, value},  {stack, return_stack, dictionary, recipients}) do
    dictionary = add_var(dictionary, name, value)
    {:noreply, {stack, return_stack, dictionary, recipients}}
  end

  # _________________implementation ___________________

  defp evaluate(words, state) do
    {stack, return_stack, dictionary, recipients} = state
    {virt_code, dictionary} = words |> parse |> interpret(dictionary) 
    run(virt_code, stack, return_stack, dictionary, recipients)
  end

end
