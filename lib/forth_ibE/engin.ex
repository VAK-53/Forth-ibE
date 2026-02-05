defmodule ForthIbE.Engin do
  @moduledoc """
  Documentation for ForthEngin.
  """
  import ForthIbE.Dictionary

  def run(virt_code, data_stack, return_stack, dictionary, recipients) do
	# IO.puts("run")
	#IO.inspect(virt_code)
	result = next(virt_code, data_stack, return_stack, dictionary, recipients)
	#IO.inspect(virt_code)
	case result do
	  {:error, reason } -> {:error, reason }
	  {_virt_code, data_stack, return_stack, dictionary, recipients} -> #IO.inspect(virt_code)
															#IO.inspect(data_stack)
															#IO.inspect(dictionary)
															{:ok, data_stack, return_stack,  dictionary, recipients}
	end
  end

  defp next([], data_stack, return_stack, dictionary, recipients) do
	{[], data_stack, return_stack,  dictionary, recipients} # ответ
  end

  defp next([%{if: true_code, else: else_code} | tail], [cond | data_stack], return_stack, dictionary, recipients) do
	#IO.puts(cond)
	branch = case cond do
	  #false	-> else_code 
	  0		-> 	else_code
	  _	-> 	true_code 	# любое? не нулевое значение
	end
	#IO.inspect(branch)
	result_code = branch ++ tail
	#IO.inspect(result_code)
	next( result_code,  data_stack, return_stack, dictionary, recipients)
  end

  defp next([first | tail], data_stack, return_stack, dictionary, recipients) when is_number(first) do
	next(tail, [first | data_stack], return_stack, dictionary, recipients)
  end

  defp next([first | tail], data_stack, return_stack, dictionary, recipients) when is_atom(first) do
	case apply(ForthIbE.Words, first, [tail, data_stack, return_stack, dictionary, recipients]) do
	  {:error, reason}	->	{:error, reason}
	  {virt_code, data_stack, return_stack, dictionary, recipients} ->
    					  next(virt_code, data_stack, return_stack, dictionary, recipients)
	end
  end

  defp next([first | tail], data_stack, return_stack, dictionary, recipients) when is_binary(first) do
	#IO.puts("binary")
	#IO.inspect(dictionary)
	case get(dictionary, first) do
	  {:words, word_code}	-> #IO.puts("word #{first}")
			next(word_code ++ tail,  data_stack, return_stack, dictionary, recipients)
	  _	->	next(tail, [first | data_stack], return_stack, dictionary, recipients)	
	end	
  end
end

