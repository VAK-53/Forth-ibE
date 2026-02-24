defmodule ForthIbE.Interpreter do
  @moduledoc """
  Модуль транслятора токенов в байт-код.
  """
  import ForthIbE.Table
  import ForthIbE.Dictionary

  def interpret(tokens, dictionary) do    # , table
    #IO.inspect(tokens)	
	derivation = case _interpret(tokens, dictionary) do        # , table            
	  {virt,  dictionary, _map} ->  #IO.inspect(virt)            # вспомогательный словарь для сбора на обратном пути
                                    {virt, dictionary}
	  {:error, reason }	        ->  {:error, reason }
	end		
	derivation
  end

  defp _interpret([], dictionary) do 	# завершение рекурсивной обработки     # , _table 
    map = %{}                                   # словарь для сборки на обратном пути конструкций if then else
	{[], dictionary, map}	 	                # 2-ой параметр отклика - это вспомогательный return_stack 
  end						

  defp _interpret([:comment | tail], dict) do   # выполняется непосредственно в трансляции     # , table
	#IO.inspect(tail)
	{_comment_code, [:end_comment | new_tokens]} = Enum.split_while(tail, fn s -> s != :end_comment end)
	_interpret(new_tokens, dict)                # возвращаем 3 параметра ?!    # , table
  end

  #-------------------------
  # ( ! )
  #-------------------------
  defp _interpret([:create | tail], dictionary) do # выполняется непосредственно при трансляции    # , table
	{word_tokens, [:end_create | behind_tokens]} = Enum.split_while(tail, fn s -> s != :end_create end)
	[ word_name | content ] = word_tokens
	# IO.inspect(content)
	case interpret(content, dictionary) do     # конвертирование binary в атомы прямо в определении    # , table
      {:error, reason } ->  { :error, "Определение не выполнено: " <> reason }

	  {virt_code, dict} ->  new_dict = add_word(dict, word_name, virt_code)												
  							_interpret(behind_tokens, new_dict)      # , table
	end
    #{virt, dict, map}
  end

  #-------------------------
  # ( if ... then ...else )
  #-------------------------
  defp _interpret(["if" | tail], dict) do	    # , table						
	{virt, dict, map} = _interpret(tail, dict)      # , table       
    #IO.inspect(virt)                                                             	
    split_result = Enum.split_while(virt, fn s -> s != "then"  end)
    case split_result do
      {virt_code, ["then" | behind_virt]}   ->  map_code = Map.put(map, :if, virt_code)          # вставляем в словарь код за if
                                                {[map_code] ++ behind_virt, dict, %{}}           # результат
      _         ->  {virt_code, ["else" | behind_virt]} = Enum.split_while(virt, fn s -> s != "else"  end)
                    map_code = Map.put(map, :if, virt_code)          # вставляем в словарь код за if
                    #IO.inspect(map)
                    {[map_code] ++ behind_virt, dict, %{}}           # результат                 
    end
  end					
#{if_virt, ["then" | behind_virt]} = Enum.split_while(virt, fn s -> s != "then"  end) # выделяем код до then

  defp _interpret(["else" | tail], dict) do		    # , table						
	{virt,  dict, map} = _interpret(tail, dict)    # echo не учитываем    # , table
    #IO.inspect(virt)
    {virt_code, ["then" | behind_virt]} = Enum.split_while(virt, fn s -> s != "then"  end)
	code_map = Map.put(map, :else, virt_code)	                    # вставляем в словарь код за else перед then
    #IO.inspect(virt_code)
	{[ "else" | behind_virt], dict, code_map}                             # словарь вернули в возвращаемый счписок
  end														            

  defp _interpret(["then" | tail],  dict) do    # , table								
	{virt_code,  dict, _map} = _interpret(tail,  dict)    # задний код за then # , table
    map = %{else: []} 	                                        # пустая пара в словаре на случай отсутствия ветки else
    #IO.inspect(virt_code)
	{ ["then" | virt_code],  dict, map}                         # внутренний код возвращаем во вспомогательном словаре
  end
  #-------------------------

  #-------------------------
  # ( variable, abort", ." )
  #-------------------------
  defp _interpret(["variable", var_name | tail],  dictionary) do # , table
	dict = add_var(dictionary, var_name, :unknown)
	_interpret(tail,  dict) #{virt_code,  dict, map} = # , table
  end

  defp _interpret(["abort\"" | tail],  dict) do # , table
	{quoted_tokens, [:end_quote | tokens]} = Enum.split_while(tail, fn s -> s != :end_quote  end)
	string = Enum.join(quoted_tokens, " ")
	#IO.puts(string)
	code_map = %{if: [string, :dot, :abort], else: []}
	{virt_code,  dict, return_stack} = _interpret(tokens,  dict)    # , table
	{[code_map | virt_code],  dict, return_stack}
  end

  defp _interpret([".\"" | tail],  dict)  do    # , table
    #IO.inspect(tail)
 	{quoted_tokens, [:end_quote | tokens]} = Enum.split_while(tail, fn s -> s != :end_quote  end)
	string = Enum.join(quoted_tokens, " ")
	#IO.puts(string)
	{virt_code,  dict, return_stack} = _interpret(tokens,  dict)    # , table
	{[string, :dot] ++ virt_code,  dict, return_stack}	
  end
  #-------------------------

  defp _interpret([token | tail],  dict)  when is_number(token) do    # , table
	{virt, dict, map} = _interpret(tail,  dict)    # , table
	{[token | virt], dict, map}
  end

  defp _interpret([token | tail],  dict)  when is_atom(token) do    # , table
	{virt, dict, map} = _interpret(tail,  dict)    # , table
	{[token | virt], dict, map}
  end

  defp _interpret([token | tail], dictionary) when is_binary(token) do # преобразуем токены и собираем virt_code,     # , table
	found = get_atom(token)    # table
    #IO.puts(token)
    #IO.inspect(found)
	case found do 
	  atom when is_atom(atom) ->  #IO.puts("this is in_built #{atom}")    # имя встроенной функции
						          {virt, dict, map} = _interpret(tail, dictionary)    # , table
					  	          {[atom | virt], dict, map}
	  {:unknown, _token}     ->   #IO.inspect(dictionary)
                                  found = get_value(dictionary, token)
                                  case found do
                                    {:words, code}      ->  {virt, dict, map} = _interpret(tail, dictionary)    # , table
					  	                                    {code ++ virt, dict, map} # убрал слияние code ++ virt
                                    {:const, value}     ->  {virt, dict, map} = _interpret(tail, dictionary)    # , table
					  	                                    {[value | virt], dict, map}
                                    {:var, _value}       ->  {virt, dict, map} = _interpret(tail, dictionary)    # , table
					  	                                    {[token | virt], dict, map}
	                                {:unknown, _name}   ->	# IO.puts("this is not bound #{token}") # строка, не функция и не константа
					                                        {virt, dict, map} = _interpret(tail, dictionary)    # , table
					                                        {[token | virt], dict, map}
	                              end
    end
  end
end


