defmodule ForthIbE.Interpreter do
  @moduledoc """
  Модуль транслятора токенов в байт-код.
  """
  import ForthIbE.Table
  import ForthIbE.Dictionary

  def interpret(tokens, state) do 
    #IO.puts("В interpret")
    #IO.inspect(tokens)            
    #IO.inspect(state)            
    _interpret(tokens, state)           
  end

  defp _interpret([], state) do 	# конец рекурсии  
	state
  end						

  defp _interpret([:comment | tail], state) do   # выполняется непосредственно в трансляции  
	#IO.inspect(tail)
	{_comment_code, [:end_comment | new_tokens]} = Enum.split_while(tail, fn s -> s != :end_comment end)
	_interpret(new_tokens, state)                # возвращаем 3 параметра ?! 
  end

  #-------------------------
  # ( ! )
  #-------------------------
  defp _interpret([:create | tail], state) do   # выполняется непосредственно при трансляции   
    {virt_code, data_stack, return_stack, dictionary} = state
	{word_tokens, [:end_create | behind_tokens]} = Enum.split_while(tail, fn s -> s != :end_create end)
	[ word_name | content ] = word_tokens

    zero_state = {[], [], [], dictionary}
	{def_code, [], [], _dict} = interpret(content, zero_state)    # конвертируем binary в атомы прямо в определении   
    new_dict  = add_word(dictionary, word_name, def_code)
    def_state = {virt_code, data_stack, return_stack, new_dict}	
    _interpret(behind_tokens, def_state)  			
  end

  #-------------------------
  # ( if ... then ...else )
  #-------------------------
  defp _interpret(["IF" | tail], state) do
    # вначале разбиваем ветвление на части
    {_vc, ds, rs, dict}	= state		                                                     					
    {intermediate, ["then" | behind_tokens]}  = Enum.split_while(tail, fn s -> s != "then"  end)
    split  = Enum.split_while(intermediate, fn s -> s != "else"  end)
    if_state = {[],ds, rs, dict} # персональное состояние для if
    {map_code, data_stack, return_stack, new_dict } = case split do
      {if_tokens,[]}                  ->    {if_code, stack, return, if_dict} = _interpret(if_tokens, if_state)
                                            if_map = %{} |> Map.put(:if, if_code)  # вставляем в словарь только код за if                                  
                                            {if_map, stack, return, if_dict}
                                          
      {if_tokens, ["else" | else_tokens]} ->  {if_code, _stack, _return, if_dict} = _interpret(if_tokens, if_state)
                                              if_map = %{} |> Map.put(:if, if_code)      # вставляем в словарь код за if

                                              #IO.puts("else tokens: #{inspect(else_tokens)}") 
                                              else_state = {[],ds, rs, if_dict}
                                              {else_code, stack, return, else_dict} = _interpret(else_tokens, else_state)
                                              #IO.puts("else code: #{inspect(else_code)}") 
                                              
                                              map = Map.put(if_map, :else, else_code)                     # вставляем в словарь код за else
                                              {map, stack, return, else_dict}
      _ ->  raise InterpretError, message: "incorrect if-else-then structure", code: intermediate              
    end
    
    # обрабатываем токены после if ... then ...else
    {behind_code, data_stack, return_stack, behind_dict} = _interpret(behind_tokens, {[], data_stack, return_stack, new_dict })
    {[map_code | behind_code], data_stack, return_stack, behind_dict}   
  end					

  defp _interpret(["IF" | tail], state) do
    # вначале разбиваем ветвление на части
    {_vc, ds, rs, dict}	= state		                                                     					
    {intermediate, ["THEN" | behind_tokens]}  = Enum.split_while(tail, fn s -> s != "THEN"  end)
    split  = Enum.split_while(intermediate, fn s -> s != "ELSE"  end)
    if_state = {[],ds, rs, dict} # персональное состояние для if
    {map_code, data_stack, return_stack, new_dict } = case split do
      {if_tokens,[]}                  ->    {if_code, stack, return, if_dict} = _interpret(if_tokens, if_state)
                                            if_map = %{} |> Map.put(:if, if_code)  # вставляем в словарь только код за if                                  
                                            {if_map, stack, return, if_dict}
                                          
      {if_tokens, ["ELSE" | else_tokens]} ->  {if_code, _stack, _return, if_dict} = _interpret(if_tokens, if_state)
                                              if_map = %{} |> Map.put(:if, if_code)      # вставляем в словарь код за if

                                              #IO.puts("else tokens: #{inspect(else_tokens)}") 
                                              else_state = {[],ds, rs, if_dict}
                                              {else_code, stack, return, else_dict} = _interpret(else_tokens, else_state)
                                              #IO.puts("else code: #{inspect(else_code)}") 
                                              
                                              map = Map.put(if_map, :else, else_code)                     # вставляем в словарь код за else
                                              {map, stack, return, else_dict}
      _ ->  raise InterpretError, message: "incorrect if-else-then structure", code: intermediate              
    end
    
    # обрабатываем токены после if ... then ...else
    {behind_code, data_stack, return_stack, behind_dict} = _interpret(behind_tokens, {[], data_stack, return_stack, new_dict })
    {[map_code | behind_code], data_stack, return_stack, behind_dict}   
  end

  #-------------------------
  # ( variable, abort", ." )
  #-------------------------
  defp _interpret(["VARIABLE", var_name | tail],  state) do 
    {virt_code, data_stack, return_stack, dictionary} = state
	new_dict = add_var(dictionary, var_name, :unknown)
	_interpret(tail,  {virt_code, data_stack, return_stack, new_dict}) 
  end

  defp _interpret(["ABORT\"" | tail],  state) do 
	{quoted_tokens, [:end_quote | tokens]} = Enum.split_while(tail, fn s -> s != :end_quote  end)
	string = Enum.join(quoted_tokens, " ")
	#IO.puts(string)
	code_map = %{if: [string, :dot, :abort], else: []}
	{virt_code,  state, return_stack} = _interpret(tokens,  state) 
	{[code_map | virt_code],  state, return_stack}
  end

  defp _interpret([".\"" | tail],  state)  do 
    #IO.puts("begin dot #{inspect(tail)}")
 	{quoted_tokens, [:end_quote | behind_tokens]} = Enum.split_while(tail, fn s -> s != :end_quote  end)
	collection = Enum.join(quoted_tokens, " ")
    #IO.puts("middle dot #{inspect(behind_tokens)}")

	behind_state = _interpret(behind_tokens,  state) 
    {behind_virt_code, data_stack, return_stack, dictionary} = behind_state
    new_virt_code =  [collection, :dot] ++ behind_virt_code
	{new_virt_code, data_stack, return_stack, dictionary}
  end
  #-------------------------

  defp _interpret([token | tail],  state)  when is_number(token) do   
	#IO.puts("is number: #{token} #{inspect tail}") 

    {virt_code, data_stack, return_stack, dictionary} = _interpret(tail,  state) 
	#IO.puts("is number: #{inspect(virt_code)}") 
    {[token | virt_code], data_stack, return_stack, dictionary}
  end

  defp _interpret([token | tail],  state)  when is_atom(token) do    
	{virt_code, data_stack, return_stack, dictionary} = _interpret(tail,  state)    
	{[token | virt_code], data_stack, return_stack, dictionary}
  end

  defp _interpret([token | tail], state) when is_binary(token) do   # преобразуем токены и собираем virt_code  
    #IO.puts("is binary: #{token} #{inspect(tail)}")
    {_virt_code, _data_stack, _return_stack, dictionary} = state
    # downcase_token = String.downcase(token)
	lookup = get_atom_from_table(token) # downcase_
    #IO.puts("нашли #{inspect(lookup)}")
	case lookup do 
	  :unknown  ->  found = get_value(dictionary, token)
                    case found do
                      # определение
                      {:words, _code}  ->    # делается простая подстановка, расширяется в executer
                                            new_state = _interpret(tail, state)    
                                            {virt_code, data_stack, return_stack, dictionary} = new_state
                                            {[token | virt_code], data_stack, return_stack, dictionary}

                      {:const, value} ->    new_state = _interpret(tail, state)    
                                            {virt_code, data_stack, return_stack, dictionary} = new_state
                                            {[value | virt_code], data_stack, return_stack, dictionary}

                      {:var, _value}  ->    new_state = _interpret(tail, state)    
                                            {virt_code, data_stack, return_stack, dictionary} = new_state
                                            {[token | virt_code], data_stack, return_stack, dictionary}

                      :unknown        ->	new_state = _interpret(tail,  state)  
                                            {virt_code, data_stack, return_stack, dictionary} = new_state
	                                        {[token | virt_code], data_stack, return_stack, dictionary}
                                            #raise InterpretError, message: "this is not bound", code: virt_code, token: token 
                    end
	  atom when is_atom(atom)   ->  new_state = _interpret(tail, state)
                                    {virt_code, data_stack, return_stack, dictionary} = new_state  
	                                #IO.puts("is binary: #{inspect(virt_code)}")
					  	            {[atom | virt_code], data_stack, return_stack, dictionary}
    end
  end
end


