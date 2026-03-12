defmodule ForthIbE.Impl.Common do

  import ForthIbE.Compouser
  import ForthIbE.Interpreter   # 
  import ForthIbE.Tokenizer		# parse
  #import ForthIbE.Dictionary

  @global_table :sys_table

  defmacro __using__(_option) do
    quote do
      @impl true
      def init({name, stocks}) do
        # заполняем таблицу встроенных слов
        if false == :lists.member(unquote(@global_table), :ets.all()) do
          :ets.new(:sys_table, [:public, :named_table])
          :ok = compouse() 
        end

	    file_names = ["in-built-words.txt"]
        {:ok, dictionary} = ForthIbE.Dictionary.init

        Process.register(self(), name)
	    state = %{forth: {[], [], [], dictionary}, sources: [], stocks: stocks} 
	    {:ok, state}
      end

      @impl true
      def handle_call({:get_var, name},  _from,  state) do 
        {:ok, {[], _data_stack, _return_stack, dictionary}} = Map.fetch(state, :forth)
        result = ForthIbE.Dictionary.get_var(dictionary, name)
        case result do
          :error -> {:reply, {:error, "не существует"}, state} 
          value -> {:reply, {:ok, value}, state} 
        end
      end

      @impl true
      def handle_cast({:add_var, name, value}, state) do 
        {:ok, {[], _data_stack, _return_stack, dictionary}} = Map.fetch(state, :forth)  # для словаря
        new_dictionary = ForthIbE.Dictionary.add_var(dictionary, name, value)
        new_state = Map.put(state, :forth, {[], _data_stack, _return_stack, new_dictionary})
        {:noreply, new_state} 
      end

      @impl true
      def handle_cast({:execute, words}, state) do 
        {:ok, {[], _data_stack, _return_stack, dictionary}} = Map.fetch(state, :forth)  # для словаря      
        result = words |> eval(state) # !!!
        case result do
          {:ok, [], new_data_stack, new_return_stack, new_dictionary } -> 
            new_state = Map.put(state, :forth, {[], new_data_stack, new_return_stack, new_dictionary})
            {:noreply, new_state}
          {:error, _reason} -> 
            new_state = Map.put(state, :forth, {[], [], [], dictionary})
            {:noreply, new_state} # добавить журналирование  
        end
      end

      defp eval(words, full_state) do
        %{forth: {_virt_code, data_stack, return_stack, dictionary}, sources: sources, stocks: stocks} = full_state 
        {virt_code, dictionary} = words |> parse |> interpret(dictionary)  
        full_state = %{forth: {virt_code, data_stack, return_stack, dictionary}, sources: sources, stocks: stocks}
        ForthIbE.Executer.evaluate(full_state) 
      end
    end
  end
end

