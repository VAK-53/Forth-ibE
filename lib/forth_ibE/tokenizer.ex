defmodule ForthIbE.Tokenizer do
  @moduledoc """
  Лексический анализатор слов
  """

  def parse(string) do
    char_list = String.to_charlist(string) 
	#IO.inspect(char_list)
    {tokens, errs} = _parse(char_list, [], nil, [], []) # начальное состояние лексера
    case errs do
      [] -> {:ok}
      _  -> IO.inspect(errs)
            {:errs}
    end
    Enum.reverse(tokens) # собираем токены на прямом пути
  end
  
  # заключительный шаг
  defp _parse([], tokens, target, previous, errs) do
	#IO.puts("самый конец")
	#IO.inspect(target) 
	#IO.inspect(previous)
	new_tokens  = save_previous(tokens, target, previous)	  
	
	{new_tokens, errs}
  end

  # tagets: nil, :integer, :float, :word, :err
  defp _parse(charlist, tokens, target, previous, errs) do
    [c | tail] = charlist
    case get_char(c) do
      :digit -> # толерантный символ по отношению к цели
			previous = [c | previous]
			target = case target do
			  nil		->  :integer
		  	  :minus	->	#IO.puts("поймал цифру")
							_parse(tail, tokens, :integer, previous, errs)
							:integer
			  :integer	->  :integer
			  :float	->  :float
			  :word		->  :word
			  :err		->  :err
			end
			_parse(tail, tokens, target, previous, errs)

      :dot ->
		previous = [c | previous]
        case target do
		  nil		-> 	_parse(tail, tokens, :dot, previous, errs)
          :integer	->  _parse(tail, tokens, :float, previous, errs)
          :float 	->  target = :err
				  	   	errs =["Символ точки не соответствует целевому токену\n" | errs]
					   	_parse(tail, tokens, target, previous, errs)
		  :word 	->  	_parse(tail, tokens, target, previous, errs) # цель не меняем, движимся далее
		  :err		->  	_parse(tail, tokens, target, previous, errs) # цель сохраняем
		end

      :quote ->
		case target do
		  :word	->  previous = [c | previous]
					# цель сохраняется
				   	_parse(tail, tokens, target, previous, errs)
		  :dot	->	previous = [c | previous]
					target = :word
				  	_parse(tail, tokens, target, previous, errs)
		  nil	->	# случай замыкающей кавычки после :space
					# текущая цель и previous не меняются
					new_tokens = save_previous(tokens, :end_quote, previous)	
					_parse(tail, new_tokens, target, previous, errs)   
		end		

	  :minus -> 
		previous = [c | previous]
		case target do
		  nil 	 -> _parse(tail, tokens, :minus, previous, errs)
		  :minus -> new_tokens = save_previous(tokens, :double_dash, previous)
					previous = []
					target = nil
				  	_parse(tail, new_tokens, target, previous, errs)
		  :word	 	-> _parse(tail, tokens, :word, previous, errs)
		  :integer	-> _parse(tail, tokens, :word, previous, errs)
		end

      :create ->  new_previous = [c | previous]
		case target do
		  :word -> 	_parse(tail, tokens, target, new_previous, errs)
		  :nil	->	target = :create
		   	   		_parse(tail, tokens, target, new_previous, errs)
		end

      :space -> 
		case target do
		  nil	 ->_parse(tail, tokens, target, previous, errs) 	# пробел  не обрабатываем, движимся далее		
		  :minus ->	new_tokens = save_previous(tokens, :minus, previous)
				  previous = [] 
				  target = nil	     
				  _parse(tail, new_tokens, target, previous, errs)
		  _   ->  # цель достигнута, сохраняем полученные символы в токене 
				  new_tokens = save_previous(tokens, target, previous)
				  previous = [] 
				  target = nil
				  _parse(tail, new_tokens, target, previous, errs)
		end

      :new_line ->
		#IO.puts("Да, я тут.")
		case target do
	      nil -> _parse(tail, tokens, target, previous, errs) # символ новой строки не обрабатываем, движимся далее			  
	      _   ->  # цели достигнуты,сохраняем полученные символы в токене 
			  tokens = save_previous(tokens, target, previous)
			  previous = [] 
			  target = nil
	  		  _parse(tail, tokens, target, previous, errs)   
	  	end

      :comment ->  new_previous = [c | previous]
			   target = :comment
		   	   _parse(tail, tokens, target, new_previous, errs)

      :end_comment ->  new_previous = [c | previous]
			   target = :end_comment
		   	   _parse(tail, tokens, target, new_previous, errs)

      :end_create ->  new_previous = [c | previous]
			   target = :end_create
		   	   _parse(tail, tokens, target, new_previous, errs)

      :any ->  new_previous = [c | previous]
			   target = :word
		   	   _parse(tail, tokens, target, new_previous, errs)

       _    ->  IO.puts("Прочитал не обработанный #{<<c>>} в лексере. ?")
    end
  end

  defp save_previous(tokens, target, previous) do
	case target do 
	  nil -> tokens
	  _   -> lexem = previous
		     |>  Enum.reverse()
			 |>  List.to_string()
			 token = case target do
				:integer		-> String.to_integer(lexem)
				:float			-> String.to_float(lexem)
				:word 			-> String.downcase(lexem) # слова безразличны к регистру 
				:minus	 		-> :minus
				:double_dash	-> :double_dash
				:comment 		-> :comment
				:dot 	 		-> :dot
				:end_comment 	-> :end_comment
				#:start_quote 	-> :start_quote удалить
				:end_quote 		-> :end_quote
				:create 		-> :create
				:end_create 	-> :end_create
		  	 end
			 [token | tokens]
	end
  end


  defp get_char(?\s), do: :space
  defp get_char(?\t), do: :space
  defp get_char(?\n), do: :new_line
  defp get_char(char) when char in ~c"0123456789", do: :digit
  defp get_char(?-),  do: :minus
  defp get_char(?.),  do: :dot    
  defp get_char(?\"), do: :quote                  
  defp get_char(?(),  do: :comment
  defp get_char(?)),  do: :end_comment
  defp get_char(?:),  do: :create
  defp get_char(?;),  do: :end_create
  defp get_char(_),   do: :any
end
