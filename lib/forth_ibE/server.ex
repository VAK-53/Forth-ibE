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

  @global_table :sys_table

  @impl GenServer
  def init({name, recipients}) do
   	file_names = [ "math_words.json", "io_words.json", "interpret_words.json", "flow_words.json", 
				 "logic_words.json", "stack_words.json", "time_words.json", "interprocess_words.json",
                 "conversion_words.json"] 
    if false == :lists.member(@global_table, :ets.all()) do
      :ets.new(:sys_table, [:public, :named_table])
      :ok = compouse(file_names) 
    end
    #:ets.tab2list(:sys_table) |> IO.inspect

	stack = []
	return_stack = []
    {:ok, dictionary} = ForthIbE.Dictionary.init()
    #atom_name = String.to_atom(name)
    Process.register(self(), name)
	state = {stack, return_stack, dictionary, recipients}   #, table
	{:ok, state}
  end

  @impl true
  def handle_call({:get_var, name},  _from,  {stack, return_stack, dictionary, recipients} = _state) do #, table
    result = get_var(dictionary, name)
    case result do
      :error -> {:reply, {:error, "не существует"}, {stack, return_stack, dictionary, recipients}} #, table
      value -> {:reply, {:ok, value}, {stack, return_stack, dictionary, recipients}} #, table
    end
  end

  @impl true
  def handle_cast({:execute, words}, {_stack, _return_stack, dictionary, recipients} = state) do #, table
    result = words |> eval(state)
    case result do
      {:ok, stack, return_stack, dictionary } -> {:noreply, {stack, return_stack, dictionary, recipients}} #, table
      {:error, _reason} -> {:noreply, {[], [], dictionary, recipients}} # добавить журналирование  #, table
    end
  end

  @impl true
  def handle_cast({:add_var, name, value},  {stack, return_stack, dictionary,  recipients}) do #, table
    dictionary = add_var(dictionary, name, value)
    {:noreply, {stack, return_stack, dictionary, recipients}} #, table
  end

  # _________________implementation ___________________

  defp eval(words, state) do
    {stack, return_stack, dictionary, recipients} = state #, table
    {virt_code, dictionary} = words |> parse |> interpret(dictionary)  #, table
    evaluate(virt_code, stack, return_stack, dictionary,  recipients) #, table
  end

end
