defmodule ForthIbE.Server do
  @moduledoc """
  Documentation for `ForthIbE`.
  """
  use GenServer
  import ForthIbE.Compouser
  import ForthIbE.Interpreter   # 
  #import ForthIbE.Engin		# evaluate
  import ForthIbE.Tokenizer		# parse
  import ForthIbE.Dictionary

  @global_table :sys_table

  @impl GenServer
  def init({name, stocks}) do
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
	state = {stack, return_stack, dictionary, stocks}   
	{:ok, state}
  end

  @impl true
  def handle_call({:get_var, name},  _from,  {stack, return_stack, dictionary, stocks} = _state) do 
    result = get_var(dictionary, name)
    case result do
      :error -> {:reply, {:error, "не существует"}, {stack, return_stack, dictionary, stocks}} 
      value -> {:reply, {:ok, value}, {stack, return_stack, dictionary, stocks}} 
    end
  end

  @impl true
  def handle_cast({:execute, words}, {_stack, _return_stack, dictionary, stocks} = state) do 
    result = words |> eval(state)
    case result do
      {:ok, stack, return_stack, dictionary } -> {:noreply, {stack, return_stack, dictionary, stocks}} 
      {:error, _reason} -> {:noreply, {[], [], dictionary, stocks}} # добавить журналирование  
    end
  end

  @impl true
  def handle_cast({:add_var, name, value},  {stack, return_stack, dictionary,  stocks}) do 
    dictionary = add_var(dictionary, name, value)
    {:noreply, {stack, return_stack, dictionary, stocks}} 
  end

  # _________________implementation ___________________

  defp eval(words, state) do
    {data_stack, return_stack, dictionary, stocks} = state 
    {virt_code, dictionary} = words |> parse |> interpret(dictionary)  
    full_state = {{virt_code, data_stack, return_stack, dictionary}, stocks}
    ForthIbE.Engin.evaluate(full_state) 
  end

end
