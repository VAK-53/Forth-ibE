defmodule ForthIbE.Engin do
  @moduledoc """
  Documentation for ForthEngin.
  """
  import ForthIbE.Dictionary
  import ForthIbE.Utils

  def evaluate(full_state) do 
    {{virt_code, data_stack, return_stack, dictionary}, stocks} = full_state

	result = next({virt_code, data_stack, return_stack, dictionary}, stocks) 
	case result do
	  {:error, reason } -> {:error, reason }
	  {[], data_stack, return_stack, dictionary} ->    #IO.inspect(data_stack)
													   #IO.inspect(dictionary)
                                                       #IO.puts("Возвращаю результат")
													   {:ok, data_stack, return_stack, dictionary} #??? , stocks
	end
  end

  defp next({[], data_stack, return_stack, dictionary}, _stocks) do #, _table
	{[], data_stack, return_stack,  dictionary}     # ответ
  end                                               # stocks больше не пригодится

  defp next({[first | tail], data_stack, return_stack, dictionary}, stocks) when is_number(first) do 
    #IO.inspect(first)
	next({tail, [first | data_stack], return_stack, dictionary}, stocks) 
  end

  defp next({[first | tail], data_stack, return_stack, dictionary}, stocks) when is_atom(first) do 
	#IO.inspect(first)
    case apply(ForthIbE.Words, first, [tail, data_stack, return_stack, dictionary, stocks]) do 
	  {:error, reason}	->	{:error, reason}
	  {virt_code, data_stack, return_stack,  dict, stocks} -> #IO.puts("выполнили функцию #{first}")
                            #IO.inspect(virt_code)
                            #IO.inspect(data_stack)
    					    next({virt_code, data_stack, return_stack, dict}, stocks) 
	end
  end

  # эта работа выполнена в интерпретаторе!
  defp next({[first | tail], data_stack, return_stack, dictionary}, stocks) when is_binary(first) do  
	#IO.puts("binary в engine")
	#IO.puts(first)
    #IO.inspect(dictionary)
	case get_value(dictionary, first) do
	  {:words, word_code}	->  virt_code = word_code ++ tail
                                #IO.inspect(word_code)
			                    next({virt_code,  data_stack, return_stack, dictionary}, stocks) 
	  _	                    ->  next({tail, [first | data_stack], return_stack, dictionary}, stocks)	 
	end	
  end

  defp next({[map | tail], [flag | s_tail], return_stack, dictionary}, stocks) when is_map(map) do 
	#IO.puts("map в engine")
    #IO.inspect(flag)
	case is_falsely(flag) do
	  true  ->    case Map.get(map, :else) do
                    :error  ->  {:error, "В операторе if почему то отсутствует else." }
			        []      ->  #IO.puts("пустой else")
                                #IO.inspect(tail)
                                #IO.inspect(s_tail)
                                next({tail, s_tail, return_stack, dictionary}, stocks) 
                    code    ->  next({code ++ tail, s_tail, return_stack, dictionary}, stocks) 
                  end
	  false ->    code = Map.get(map, :if)
                  #IO.inspect(code)
                  #IO.inspect(tail)
                  recurse_code = code ++ tail
                  #IO.inspect(recurse_code)
                  next({recurse_code, s_tail, return_stack, dictionary}, stocks) 
	end	
  end
end

