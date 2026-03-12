defmodule ForthIbE.GenEngine do
  use GenServer

  #import ForthIbE.Compouser
  import ForthIbE.Interpreter
  import ForthIbE.Tokenizer    # parse

  @global_table :sys_table

  @impl true
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
    {:ok, {[], _data_stack, _return_stack, dictionary}} = Map.fetch(full_state, :forth)
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
                                    {time_min, time_max} = Enum.reduce(new_sources, {2147483647, 0}, fn {_, _, timestamp}, acc ->  
                                                        if timestamp < elem(acc, 0) do
                                                          put_elem(acc, 0, timestamp)
                                                        else if timestamp > elem(acc, 1) do
                                                          put_elem(acc, 1, timestamp)
                                                        else acc
                                                        end end
                                                                                end)
                                    dispersion = Application.fetch_env!(:gen_engine, :dispersion)
                                    if (time_max - time_min) > dispersion do
                                      # послать сообщение диспетчеру
                                      {:noreply, new_state}
                                    else
                                      # "толкнуть" движок
                                      result = "run" |> eval(new_state)
                                      case result do
                                        {:ok, [], data_stack, return_stack, dictionary } -> 
                                            state = new_state |> Map.put(:forth, {[], data_stack, return_stack, dictionary})
                                            {:noreply, state}
                                        {:error, _reason} -> 
                                            state = new_state |> Map.put(:forth, {[], [], [], dictionary})
                                            {:noreply, state} 
                                            # добавить журналирование  
                                      end
                                    end
                        end
     end
  end

  defp eval(words, full_state) do
    %{forth: {_virt_code, data_stack, return_stack, dictionary}, sources: sources, stocks: stocks} = full_state 
    {virt_code, dictionary} = words |> parse |> interpret(dictionary)  
    full_state = %{forth: {virt_code, data_stack, return_stack, dictionary}, sources: sources, stocks: stocks}
    ForthIbE.Executer.evaluate(full_state) 
  end

end
