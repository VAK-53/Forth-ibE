defmodule ForthIbE.Engin do
  @moduledoc """
  Documentation for ForthEngin.
  """
  import ForthIbE.Dictionary
  import ForthIbE.Utils

  def evaluate(virt_code, data_stack, return_stack, dictionary, recipients) do #, table
	#IO.puts("evaluate")
	#IO.inspect( dictionary)
	#IO.inspect(virt_code)

	result = next(virt_code, data_stack, return_stack, dictionary, recipients) #, table
	case result do
	  {:error, reason } -> {:error, reason }
	  {[], data_stack, return_stack, dictionary} ->    #IO.inspect(data_stack)
													   #IO.inspect(dictionary)
                                                       #IO.puts("Возвращаю результат")
													   {:ok, data_stack, return_stack, dictionary} #??? , recipients
	end
  end

  defp next([], data_stack, return_stack, dictionary, _recipients) do #, _table
	{[], data_stack, return_stack,  dictionary}     # ответ
  end                                               # recipients больше не пригодится

  defp next([first | tail], data_stack, return_stack, dictionary, recipients) when is_number(first) do #, table
	#IO.puts("number")
    #IO.inspect(first)
	next(tail, [first | data_stack], return_stack, dictionary, recipients) #, table
  end

  defp next([first | tail], data_stack, return_stack, dictionary, recipients) when is_atom(first) do #, table
	#IO.puts("atom")
	#IO.inspect(first)
    case apply(ForthIbE.Words, first, [tail, data_stack, return_stack, dictionary, recipients]) do 
	  {:error, reason}	->	{:error, reason}
	  {virt_code, data_stack, return_stack,  dict, recipients} -> #IO.puts("выполнили функцию #{first}")
                            #IO.inspect(virt_code)
                            #IO.inspect(data_stack)
    					    next(virt_code, data_stack, return_stack, dict, recipients) #, table
	end
  end

  # эта работа выполнена в интерпретаторе!
  defp next([first | tail], data_stack, return_stack, dictionary, recipients) when is_binary(first) do  #, table
	#IO.puts("binary в engine")
	#IO.puts(first)
    #IO.inspect(dictionary)
	case get_value(dictionary, first) do
	  {:words, word_code}	->  virt_code = word_code ++ tail
                                #IO.inspect(word_code)
			                    next(virt_code,  data_stack, return_stack, dictionary, recipients) #, table
	  _	                    ->  next(tail, [first | data_stack], return_stack, dictionary, recipients)	 #, table
	end	
  end

  defp next([map | tail], [flag | s_tail], return_stack, dictionary, recipients) when is_map(map) do #, table
	#IO.puts("map в engine")
    #IO.inspect(flag)
	case is_falsely(flag) do
	  true  ->    case Map.get(map, :else) do
                    :error  ->  {:error, "В операторе if почему то отсутствует else." }
			        []      ->  #IO.puts("пустой else")
                                #IO.inspect(tail)
                                #IO.inspect(s_tail)
                                next(tail,  s_tail, return_stack, dictionary, recipients) #, table
                    code    ->  next(code ++ tail, s_tail, return_stack, dictionary, recipients) #, table
                  end
	  false ->    code = Map.get(map, :if)
                  #IO.inspect(code)
                  #IO.inspect(tail)
                  recurse_code = code ++ tail
                  #IO.inspect(recurse_code)
                  next(recurse_code, s_tail, return_stack, dictionary, recipients) #, table
	end	
    	
  end
end

