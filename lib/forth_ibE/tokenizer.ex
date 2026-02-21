defmodule ForthIbE.Tokenizer do
  @moduledoc """
  Лексический анализатор слов
  """

  def parse(string) do
    char_list = String.to_charlist(string <> "\n") 
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
    #IO.puts(target)
	new_tokens  = save_previous(tokens, target, previous)	  	
	{new_tokens, errs}
  end

  # tagets: nil, :integer, :float, :word, :err
  defp _parse(charlist, tokens, target, previous, errs) do
    [c | tail] = charlist
    #IO.puts(c)
    case get_char(c) do
      :digit -> # толерантный символ по отношению к цели
        #IO.puts(c)    
		previous = [c | previous]
		target = case target do
                  nil		->  :integer
              	  :minus	->	# унарный минус
				                _parse(tail, tokens, :integer, previous, errs)
				                :integer
                  :integer	->  :integer
                  :float	->  :float
                  :word		->  :word
                  :phrase   ->  :phrase
                  :err		->  :err
        end
			_parse(tail, tokens, target, previous, errs)

      :dot ->
		previous = [c | previous]
        case target do
		  nil		-> 	target = :dot
                        _parse(tail, tokens, target, previous, errs)
          :integer	->  _parse(tail, tokens, :float, previous, errs)
          :float 	->  target = :err
				  	   	errs =["Символ точки не соответствует целевому токену\n" | errs]
					   	_parse(tail, tokens, target, previous, errs)
		  :word 	->  _parse(tail, tokens, target, previous, errs) # цель не меняем, движимся далее
          :phrase   ->  _parse(tail, tokens, target, previous, errs) # цель сохраняем, движимся далее    
		  :err		->  _parse(tail, tokens, target, previous, errs) # цель сохраняем
		end

      :quote -> 
        #IO.inspect(previous)
		case target do
		  :phrase   ->	new_tokens = save_previous(tokens, target, previous) # закрываем
				        previous = [] 
				        target = nil
                        _parse(tail, new_tokens, target, previous, errs)
		  :word	    ->  previous = [c | previous]
				       	_parse(tail, tokens, target, previous, errs) # цель сохраняется
		  :dot      ->  previous = [c | previous]
				      	_parse(tail, tokens, :word, previous, errs) 
		  nil	    ->	# случай открывающей или закрывающей кавычки после :space 
                        case tail do
                          []    ->  previous = [ c ]
                                    target = :end_quote
                                    _parse([], tokens, target, previous, errs)
                          _     ->  [following_c | _new_tail] = tail     # забегаем вперед на один символ
                                    case get_char(following_c) do
                                      :space -> # это конец
                                                previous = [ c ]
					                         	_parse(tail, tokens, :end_quote, previous, errs)
                                      :digit  ->  _parse(tail, tokens, :phrase, previous, errs)
                                      :any    ->  _parse(tail, tokens, :phrase, previous, errs)
                                    end
                        end     
		end		
    
	  :minus -> previous = [c | previous]
		case target do
		  nil 	    -> _parse(tail, tokens, :minus, previous, errs)
		  :word	 	-> _parse(tail, tokens, :word, previous, errs)
		  :phrase	-> _parse(tail, tokens, :phrase, previous, errs)
		  :integer  -> _parse(tail, tokens, :word, previous, errs)
		  :any      -> _parse(tail, tokens, :word, previous, errs)
		  :minus    -> _parse(tail, tokens, :word, previous, errs)
		end

      :create ->  new_previous = [c | previous]
		case target do
		  :phrase   ->  _parse(tail, tokens, :phrase, new_previous, errs)
		  :word     -> 	_parse(tail, tokens, target, new_previous, errs)
		  :nil      ->	target = :create
		   	   		    _parse(tail, tokens, target, new_previous, errs)
		end

      :space -> 
        #IO.puts(previous)
		case target do
          :end_quote ->  new_tokens   = save_previous(tokens, :end_quote, previous)
                        previous = []
                        _parse(tail, new_tokens, nil, previous, errs)
		  :phrase	->  new_previous = [c | previous] 
                        _parse(tail, tokens, :phrase, new_previous, errs)
		  nil	    ->  _parse(tail, tokens, target, previous, errs) 	# пробел  не обрабатываем, движимся далее		
		  :minus    ->	new_tokens = save_previous(tokens, :minus, previous)
				        previous = [] 
				        target = nil	     
				        _parse(tail, new_tokens, target, previous, errs)
		   _        ->  # цель достигнута, сохраняем полученные символы в токене 
				        new_tokens = save_previous(tokens, target, previous)
				        previous = [] 
				        target = nil
				        _parse(tail, new_tokens, target, previous, errs)
		end

      :new_line -> 
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

      :any -> 
              new_previous = [c | previous]
			  case target do
                :word       ->  _parse(tail, tokens, :word, new_previous, errs)
                :dot        ->  _parse(tail, tokens, :word, new_previous, errs)
                nil         ->  _parse(tail, tokens, :word, new_previous, errs)
                :integer    ->  _parse(tail, tokens, :word, new_previous, errs)
                #:minus      ->  _parse(tail, tokens, target, new_previous, errs)
              end

       _    ->  IO.puts("Прочитал не обработанный #{<<c>>} в лексере. ?")
    end
  end

  defp save_previous(tokens, target, previous) do
	case target do 
	  nil -> tokens
	  _   -> lexem = previous
		     |>  Enum.reverse()
			 |>  List.to_string()
             #IO.puts(lexem)
			 token = case target do
				:integer		-> String.to_integer(lexem)
				:float			-> String.to_float(lexem)
				:word 			-> String.downcase(lexem) # слова безразличны к регистру 
                :phrase         -> lexem
				:minus	 		-> :minus
				:double_dash	-> :double_dash
				:comment 		-> :comment
				:dot 	 		-> :dot
				:end_comment 	-> :end_comment
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
  defp get_char(_),   do: :any      # ??!
end
