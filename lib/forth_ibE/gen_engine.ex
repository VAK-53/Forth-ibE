defmodule ForthIbE.GenEngine do
  use GenServer

  #import ForthIbE.Compouser
  #import ForthIbE.Interpreter
  #import ForthIbE.Tokenizer    # parse
  #import ForthIbE.Dictionary

  @global_table :sys_table

  @impl GenServer
  def init({name, sources, stocks}) do   # source словарь переменных; stocks список потребителей
    # заполняем таблицу встроенных слов
    if false == :lists.member(@global_table, :ets.all()) do
      :ets.new(:sys_table, [:public, :named_table])
      :ok = ForthIbE.Compouser.compouse() 
    end
    #:ets.tab2list(:sys_table) |> IO.inspect

    {:ok, dictionary} = ForthIbE.Dictionary.init()

    Process.register(self(), name)
	state = %{forth: {[], [], [], dictionary}, sources: sources, stocks: stocks} 
	{:ok, state}
  end
  
  @impl true
  def handle_cast({:put, name, value, timestamp}, full_state) do 
    case Map.fetch(full_state, :sources) do
      :error ->  # послать сообщение диспетчеру о внутренней ошибке, добавить журналирование 
                {:noreply, full_state}
      {:ok, sources} -> case Map.has_key?(sources, name) do
                          :false ->  # послать сообщение диспетчеру об ошибке обращения, добавить журналирование 
                                    {:noreply, full_state}
                          :true  -> # заменить значение в словаре и состояние
                                    new_sources = Map.put(sources, name, {value, timestamp})
                                    new_state   = Map.put(full_state, :sources, new_sources)
                                    # найти min и max временных меток
                                    Enum.reduce(new_sources, {2147483647, 0}, fn {_, _, timestamp}, acc ->  
                                                        acc = if timestamp < elem(acc, 0), do: put_elem(acc, 0, timestamp), else: acc
                                                        acc = if timestamp > elem(acc, 1), do: put_elem(acc, 1, timestamp), else: acc
                                                                                end)
                                    
                                    #....
                                    {:noreply, new_state}
                        end
     end
  end
end
