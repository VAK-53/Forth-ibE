defmodule ForthIbE.Server do
  @moduledoc """
  Documentation for `ForthIbE`.
  """
  use GenServer
  import ForthIbE.Compouser
  import ForthIbE.Interpreter   # 
  import ForthIbE.Engin			# evaluate
  import ForthIbE.Tokenizer		# parse
  import ForthIbE.Dictionary


  @impl GenServer
  def init({name, recipients}) do
	{:ok, table} = ForthIbE.Table.init()
    {:ok, table} = compouse(table) 
	stack = []
	return_stack = []
    {:ok, dictionary} = ForthIbE.Dictionary.init()
    atom_name    = String.to_atom(name)
    Process.register(self(), atom_name)
	state = {stack, return_stack, dictionary, table, recipients}
	{:ok, state}
  end

  @impl true
  def handle_call({:get_var, name},  _from,  {stack, return_stack, dictionary, table, recipients} = _state) do
    result = get_var(dictionary, name)
    case result do
      :error -> {:reply, {:error, "не существует"}, {stack, return_stack, dictionary, table, recipients}}
      value -> {:reply, {:ok, value}, {stack, return_stack, dictionary, table, recipients}}
    end
  end

  @impl true
  def handle_cast({:execute, words}, {_stack, _return_stack, dictionary, table, recipients} = state) do
    result = words |> eval(state)
    case result do
      {:ok, stack, return_stack, dictionary } -> {:noreply, {stack, return_stack, dictionary, table, recipients}}
      {:error, _reason} -> {:noreply, {[], [], dictionary, table, recipients}} # добавить журналирование
    end
  end

  @impl true
  def handle_cast({:add_var, name, value},  {stack, return_stack, dictionary, table,  recipients}) do
    dictionary = add_var(dictionary, name, value)
    {:noreply, {stack, return_stack, dictionary, table, recipients}}
  end

  # _________________implementation ___________________

  defp eval(words, state) do
    {stack, return_stack, dictionary, table, recipients} = state
    {virt_code, dictionary} = words |> parse |> interpret(dictionary, table) 
    evaluate(virt_code, stack, return_stack, dictionary, table,  recipients)
  end

end
