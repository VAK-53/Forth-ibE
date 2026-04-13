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
        # Добавляем врождённые параметры движка монады
        new_dictionary = dictionary |> ForthIbE.Dictionary.add_var("_ENG_NAME", name) |>
                         ForthIbE.Dictionary.add_var("_STOCKS", stocks)
	    state = %{forth: {[], [], [], new_dictionary}, sources: [], stocks: stocks} 
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
      def handle_call(:get_stocks,  _from,  state) do 
        stocks = Map.fetch(state, :stocks)
        {:reply, stocks, state} 
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
        {:ok, forth_state} = Map.fetch(state, :forth)  # для словаря  
        {_vc, _ds, _rs, dictionary} = forth_state    
        new_state = words |> eval(forth_state) # !!!
        case new_state do
          {[], new_data_stack, new_return_stack, new_dictionary } -> 
            new_state = Map.put(state, :forth, {[], new_data_stack, new_return_stack, new_dictionary})
            {:noreply, new_state}
          :error -> 
            new_state = Map.put(state, :forth, {[], [], [], dictionary})
            {:noreply, new_state} # добавить журналирование  
        end
      end

      @impl true
      def handle_info({:start_next, id, word},  state) do 
        {:ok, stocks} = Map.fetch(state, :stocks)  
        Enum.each(stocks, fn name ->
           ForthIbE.Monad.execute(name, word)  # только монады напрямую запускаются и останавливаются!?
        end)
        {:noreply, state} 
      end

      defp eval(words, state) do
        try do
          new_state = words |> parse |> interpret(state) |> ForthIbE.Executer.evaluate
        rescue
          e in ExecuterError ->
            case e.message do
              "division by zero"    ->  Logger.info("Деление на 0.")
              "negative root value" ->  Logger.info("Отрицательное подкоренное выражение.")
              "there's no declared variable" ->
                                        Logger.info("Отсутствует требуемая переменная #{e.name}.")
              "there's no need constant"     ->
                                        Logger.info("Отсутствует требуемая константа \"#{e.name}\".")
              "undefined variable"  ->  Logger.info("Значение переменной \"#{e.name}\" не определено.")         
              "not number"          ->  Logger.info("Значение \"#{e.name}\" не является числом.")             
              "an empty stack"      ->  Logger.info("Cтек пуст.")
            end
              Logger.info("Стек: #{inspect(e.stack)}")
              Logger.info("Код: #{inspect(e.code)}")
            :error
        end
      end
    end
  end
end

