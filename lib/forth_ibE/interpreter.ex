defmodule ForthIbE.Interpreter do
  @moduledoc """
  Модуль транслятора токенов в байт-код.
  """
  import ForthIbE.Dictionary

  def interpret(tokens,  dictionary) do
	#IO.inspect(tokens)	
	derivation = case _interpret(tokens, dictionary) do # return_stack - просто какой-то стек!!!	
	  {virt_code, _return_stack,  dictionary} -> {virt_code, dictionary}
	  {:error, reason }	-> 	 {:error, reason }
	end		
	# IO.inspect(derivation)
	derivation
  end

  defp _interpret([], dictionary) do 	# завершение рекурсивной обработки  
	{[], [], dictionary}	 	# 2-ой параметр отклика - это вспомогательный return_stack 
  end						

  defp _interpret([:comment | tail], dict) do # выполняется непосредственно в трансляции
	#IO.inspect(tail)
	{_comment_code, [:end_comment | new_tokens]} = Enum.split_while(tail, fn s -> s != :end_comment end)
	_interpret(new_tokens, dict) # тут возвращаем только 2 параметра ?!
  end

  defp _interpret([:create | tail], dictionary) do # выполняется непосредственно при трансляции
	{word_tokens, [:end_create | behind_tokens]} = Enum.split_while(tail, fn s -> s != :end_create end)
	[ word_name | content ] = word_tokens
	#IO.inspect(	content )
	case interpret(content,  dictionary) do# конвертирование binary в атомы прямо в определении
	  {:error, reason } -> { :error, "Определение не выполнено: " <> reason }
	  {atom_content, _dict} -> 	dict = add_word(dictionary, word_name, atom_content)													
	  							_interpret(behind_tokens, dict)	# тут возвращаем только 2 параметра ?!
	end
  end

  defp _interpret(["if" | tail], dict) do							
	{arival_virt_code, return_stack,  dict} = _interpret(tail, dict) 	# список secondary пуст?	
	[code_map | behind_virt_code] = return_stack
	code_map = Map.put(code_map, :if, arival_virt_code)
    {[code_map] ++ behind_virt_code, [], dict} 
  end					

  defp _interpret(["else" | tail], dict) do								
	{arival_virt_code, return_stack,  dict} = _interpret(tail, dict)	# echo не учитываем
	[code_map | behind_virt_code] = return_stack
	code_map = Map.put(code_map, :else, arival_virt_code)	
	{[], [code_map] ++ behind_virt_code, dict}	# код ветвления до then забрали с словарь 
														# и поместили в список
  end

  defp _interpret(["then" | tail], dict) do								# эхо не нужно?
	{behind_virt_code, _return_stack,  dict} = _interpret(tail, dict)  # за then может быть код
    code_map = %{else: []} 					# пустая пара на случай отсутствия ветки else
	{[], [code_map | behind_virt_code],  dict}  # код прячем во вспомогательном стеке
  end

  defp _interpret(["abort\"" | tail], dict) do
	{quoted_tokens, [:end_quote | tokens]} = Enum.split_while(tail, fn s -> s != :end_quote  end)
	string = Enum.join(quoted_tokens, " ")
	#IO.puts(string)
	code_map = %{if: [string, :dot, :abort], else: []}
	{virt_code, return_stack,  dict} = _interpret(tokens, dict)
	{[code_map | virt_code], return_stack,   dict}
  end

  defp _interpret([".\"" | tail], dict)  do
 	{quoted_tokens, [:end_quote | tokens]} = Enum.split_while(tail, fn s -> s != :end_quote  end)
	string = Enum.join(quoted_tokens, " ")
	#IO.puts(string)
	{virt_code, return_stack,  dict} = _interpret(tokens, dict)
	{[string, :dot] ++ virt_code, return_stack,  dict}	
  end

  defp _interpret([token | tail], dict)  when is_number(token) do
	#IO.puts("number")
	result = _interpret(tail, dict)
	answer(result, token, :insert_at_0)
  end

  defp _interpret([token | tail], dict)  when is_atom(token) do
	result = _interpret(tail, dict)
	answer(result, token, :insert_at_0)
  end

  defp _interpret([token | tail], dict) when is_binary(token) do # преобразуем токены и собираем virt_code, 
	found = get(dict, token)
	case found do 
	  {:in_built, name} 	->	#IO.puts("this is in_built #{name}") # имя встроенной функции
						result = _interpret(tail, dict)
					  	answer(result, name, :insert_at_0)
	  {:const, value}		-> 
						result = _interpret(tail, dict)
					  	answer(result, value, :insert_at_0)

	  _ 	->		# IO.puts("this is not bound #{token}") # строка, не функция и не константа
					result = _interpret(tail, dict)
					answer(result, token, :insert_at_0)
	end
  end

  defp answer({:error, reason}, _value, _op) do
 	{:error, reason}
  end

  defp answer({virt_code, return_stack,  dict}, in_element, op) do
	case op do
	  :insert_at_0 	-> {[in_element | virt_code], return_stack,  dict}
	  :concat		-> { in_element ++ virt_code, return_stack,  dict}
	  nil			-> {virt_code, return_stack,  dict}
	end
  end
end


