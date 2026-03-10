defmodule ForthIbE.Monada do
  @moduledoc """
  Documentation for `ForthIbE`.
  """
  use GenServer
  import ForthIbE.Compouser
  import ForthIbE.Interpreter   # 
  import ForthIbE.Tokenizer		# parse
  import ForthIbE.Dictionary

  @global_table :sys_table

  @impl GenServer
  def init({name, stocks}) do
    # заполняем таблицу встроенных слов
   	file_names = [ "math_words.json", "io_words.json", "interpret_words.json", "flow_words.json", 
				 "logic_words.json", "stack_words.json", "time_words.json", "interprocess_words.json",
                 "conversion_words.json"] 
    if false == :lists.member(@global_table, :ets.all()) do
      :ets.new(:sys_table, [:public, :named_table])
      :ok = compouse(file_names) 
    end
    #:ets.tab2list(:sys_table) |> IO.inspect

	file_names = ["in-built-words.txt"]
    {:ok, dictionary} = ForthIbE.Dictionary.init(file_names)

    Process.register(self(), name)
	state = %{forth: {[], [], [], dictionary}, stocks: stocks} # virt_code = [] data_stack = [] return_stack = []
	{:ok, state}
  end

  @impl true
  def handle_call({:get_var, name},  _from,  full_state) do 
    %{forth: {_virt, _stack, _return_stack, dictionary}, stocks: _stocks} = full_state
    result = get_var(dictionary, name)
    case result do
      :error -> {:reply, {:error, "не существует"}, full_state} 
      value -> {:reply, {:ok, value}, full_state} 
    end
  end

  @impl true
  def handle_cast({:add_var, name, value},  full_state) do 
    %{forth: {virt, stack, return_stack, dictionary}, stocks: stocks} = full_state
    dictionary = add_var(dictionary, name, value)
    {:noreply, %{forth: {virt, stack, return_stack, dictionary}, stocks: stocks}} 
  end

  @impl true
  def handle_cast({:execute, words}, full_state) do 
    %{forth: {_virt, _stack, _return_stack, dictionary}, stocks: stocks} = full_state
    result = words |> eval(full_state)
    case result do
      {:ok, [], data_stack, return_stack, dictionary } -> {:noreply, %{forth: {[], data_stack, return_stack, dictionary}, stocks: stocks }}
      {:error, _reason} -> {:noreply, %{forth: {[], [], [], dictionary}, stocks: stocks}} # добавить журналирование  
    end
  end

  # _________________implementation ___________________

  defp eval(words, full_state) do
    %{forth: {_virt_code, data_stack, return_stack, dictionary}, stocks: stocks} = full_state 
    {virt_code, dictionary} = words |> parse |> interpret(dictionary)  
    full_state = %{forth: {virt_code, data_stack, return_stack, dictionary}, stocks: stocks}
    ForthIbE.Executer.evaluate(full_state) 
  end

end
