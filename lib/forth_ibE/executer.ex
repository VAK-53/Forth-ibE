defmodule ForthIbE.Executer do
  @moduledoc """
  Documentation for ForthExecuter.
  """
  import ForthIbE.Dictionary
  #import ForthIbE.Words
  import ForthIbE.Utils

  def evaluate(state) do 
    #IO.inspect(state)
	state |> 
    next 
  end

  defp next({[], data_stack, return_stack, dictionary}) do 
	{[], data_stack, return_stack,  dictionary}   
  end                                              

  defp next({[first | tail], data_stack, return_stack, dictionary}) when is_number(first) do 
    #IO.inspect(first)
	next({tail, [first | data_stack], return_stack, dictionary}) 
  end

  defp next({[first | tail], data_stack, return_stack, dictionary}) when is_atom(first) do 
    #IO.puts("в is_atom")
	#IO.inspect(first)
	#IO.inspect(tail)
    apply(ForthIbE.Words, first, [tail, data_stack, return_stack, dictionary]) |>
    next
  end

  defp next({[first | tail], data_stack, return_stack, dictionary}) when is_binary(first) do  
    #IO.puts("в is_binary #{first}")
	#IO.inspect(first)
    #IO.inspect(data_stack)
	case get_value(dictionary, first) do
      :unknown              ->  next({tail, [first | data_stack], return_stack, dictionary})
      {:var, :unknown}      ->  next({tail, [first | data_stack], return_stack, dictionary})
      {:var, _value}        ->  next({tail, [first | data_stack], return_stack, dictionary})
      # работа по расширению кода выполняется здесь ради рекурсии! 
	  {:words, word_code}   ->  virt_code = word_code ++ tail   # для рекурсии
                                #IO.inspect(data_stack)
                                #IO.inspect(virt_code)
 		                        next({virt_code,  data_stack, return_stack, dictionary}) 
	  	 
	end	
  end

  defp next({[map | tail], [flag | s_tail], return_stack, dictionary}) when is_map(map) do 
	#IO.puts("map в engine")
    #IO.inspect(flag)
	case is_falsely(flag) do
	  false ->  case Map.get(map, :if) do
                  code when is_list(code) ->  next({code ++ tail, s_tail, return_stack, dictionary}) 
			      _     ->  raise InterpretError, message: "incorrect if-else-then structure", code: tail
                end
	  true  ->  case Map.get(map, :else) do
                  code when is_list(code) ->   next({code ++ tail, s_tail, return_stack, dictionary}) 
                  _    ->   next({tail, s_tail, return_stack, dictionary})
                end
	end	
  end
end

