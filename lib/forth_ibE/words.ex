defmodule ForthIbE.Words do
  @moduledoc """
  Встроенные функции поддержки слов
  """
 
  import ForthIbE.Dictionary
  import ForthIbE.Utils
  #import SysTimer

  #----------
  # math
  #----------
  def plus(virt_code, [y, x | data_stack], return_stack, dictionary) do
    if !is_number(x) do 
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x end
    if !is_number(y) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: y end 
    {virt_code, [x + y | data_stack], return_stack, dictionary}
  end

  def minus(virt_code, [y, x | data_stack], return_stack, dictionary) do
    if !is_number(x) do 
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x end
    if !is_number(y) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: y end 
    {virt_code, [x - y | data_stack], return_stack, dictionary}
  end

  def mult(virt_code, [y, x | data_stack], return_stack, dictionary) do
    if !is_number(x) do 
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x end
    if !is_number(y) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: y end 
    {virt_code, [x * y | data_stack], return_stack, dictionary}
  end

  def div(virt_code, [y, x | data_stack], return_stack, dictionary) do
    if !is_number(x) do 
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x end
    if !is_number(y) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: y end 
	case y do
	  0 -> 	raise ExecuterError, message: "division by zero", code: virt_code, stack: data_stack, dict: dictionary
      _ -> 	{virt_code, [x / y | data_stack], return_stack, dictionary}
	end
  end

  def mod(virt_code, [y, x | data_stack], return_stack, dictionary) do
    if !is_number(x) do 
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x end
    if !is_number(y) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: y end 
    {virt_code, [ rem(x, y) | data_stack], return_stack, dictionary}
  end

  def div_mod(virt_code, [y, x | data_stack], return_stack, dictionary) do
    if !is_number(x) do 
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x end
    if !is_number(y) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: y end 
    {virt_code, [div(x, y), rem(x, y) | data_stack], return_stack, dictionary}
  end

  def pow(virt_code, [y, x | data_stack], return_stack, dictionary) do
    if !is_number(x) do 
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x end
    if !is_number(y) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: y end 
    {virt_code, [:math.pow(x, y) | data_stack], return_stack, dictionary}
  end

  def mult_div(virt_code, [x, y, z | data_stack], return_stack, dictionary) do
    {virt_code, [x*y/z| data_stack], return_stack, dictionary}
  end

  def one_plus(virt_code, [x | data_stack], return_stack, dictionary) do
    if !is_number(x) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x
    end
    {virt_code, [x + 1 | data_stack], return_stack, dictionary}
  end

  def one_minus(virt_code, [x | data_stack], return_stack, dictionary) do
    if !is_number(x) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x
    end
    {virt_code, [x - 1 | data_stack], return_stack, dictionary}
  end

  def two_mult(virt_code, [x | data_stack], return_stack, dictionary) do
    if !is_number(x) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x
    end
    {virt_code, [2 * x | data_stack], return_stack, dictionary}
  end

  def two_div(virt_code, [x | data_stack], return_stack, dictionary) do
    if !is_number(x) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x
    end
    {virt_code, [ x / 2 | data_stack], return_stack, dictionary}
  end

  def negate(virt_code, [x | data_stack], return_stack, dictionary) do
    if !is_number(x) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x end
    {virt_code, [-x | data_stack], return_stack, dictionary}
  end

  def forth_abs(virt_code, [x | data_stack], return_stack, dictionary) do
    if !is_number(x) do
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x
    end
    {virt_code, [abs(x) | data_stack], return_stack, dictionary}
  end

  def rand(virt_code, data_stack, return_stack, dictionary) do
    {virt_code, [:rand.uniform() | data_stack], return_stack, dictionary}
  end

  def min(virt_code, [y, x | data_stack], return_stack, dictionary) do
    if !is_number(x) do 
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x end
    if !is_number(y) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: y end 
    {virt_code, [min(x, y) | data_stack], return_stack, dictionary}
  end

  def max(virt_code, [y, x | data_stack], return_stack, dictionary) do
    if !is_number(x) do 
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x end
    if !is_number(y) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: y end 
    {virt_code, [max(x, y) | data_stack], return_stack, dictionary}
  end

  def sqrt(virt_code, [x | data_stack], return_stack, dictionary) do
    if !is_number(x) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x
    end
	case x do
	  x when x < 0 -> 	raise ExecuterError, message: "negative root value", code: virt_code, stack: data_stack, dict: dictionary
      _ -> 	{virt_code, [:math.sqrt(x) | data_stack], return_stack, dictionary}
	end  
  end

  def sin(virt_code, [x | data_stack], return_stack, dictionary) do
    if !is_number(x) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x
    end
    {virt_code, [:math.sin(x) | data_stack], return_stack, dictionary}
  end

  def cos(virt_code, [x | data_stack], return_stack, dictionary) do
    if !is_number(x) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x
    end
    {virt_code, [:math.cos(x) | data_stack], return_stack, dictionary}
  end

  def tan(virt_code, [x | data_stack], return_stack, dictionary) do
    if !is_number(x) do
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x
    end
    {virt_code, [:math.tan(x) | data_stack], return_stack, dictionary}
  end

  def pi(virt_code, data_stack, return_stack, dictionary) do
    {virt_code, [:math.pi()| data_stack], return_stack, dictionary}
  end

  # logic
  @c_true -1 #true
  @c_false 0 #false

  #defguard is_falsely(value) when value == false or value == nil or value == 0 or value == ""
  #defguard is_truthly(value) when not is_falsely(value)

  def eq(virt_code, [y, x | data_stack], return_stack, dictionary) do	# равенство двух элементов
    if !is_number(x) do 
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x end
    if !is_number(y) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: y end 
	result = case x == y do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [ result | data_stack], return_stack, dictionary}
  end

  def zeq(virt_code, [x | data_stack], return_stack, dictionary) do	# вершина равена нулю
    if !is_number(x) do
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x
    end
	result = case x == 0 do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary}
  end

  def neq(virt_code, [ y, x | data_stack], return_stack, dictionary) do	# отрицание элемента
    if !is_number(x) do 
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x end
    if !is_number(y) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: y end 
    {virt_code, [x != y| data_stack], return_stack, dictionary}
  end

  def lt(virt_code, [y, x | data_stack], return_stack, dictionary) do	# вершина меньше второго элемента
    if !is_number(x) do 
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x end
    if !is_number(y) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: y end 
	result = case x < y do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary}
  end

  def lte(virt_code, [y, x | data_stack], return_stack, dictionary) do	# вершина меньше или равна второму элементу
    if !is_number(x) do 
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x end
    if !is_number(y) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: y end 
	result = case x <= y do
	  true 	-> @c_true
	  false	-> @c_false
	end
    #IO.inspect(virt_code)
    #IO.inspect(result)
    {virt_code, [result | data_stack], return_stack, dictionary}
  end

  def gt(virt_code, [y, x | data_stack], return_stack, dictionary) do	# вершина больше второго элемента
    if !is_number(x) do 
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x end
    if !is_number(y) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: y end 
 	result = case x > y  do
	  true 	-> @c_true
	  false	-> @c_false
	end
   {virt_code, [result | data_stack], return_stack, dictionary}
  end

  def gte(virt_code, [y, x | data_stack], return_stack, dictionary) do	# вершина больше или равна второму элементу
    if !is_number(x) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x end
    if !is_number(y) do
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: y  end
 	result = case x >= y  do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary}
  end

  def zle(virt_code, [x | data_stack], return_stack, dictionary) do	# вершина меньше нуля
    if !is_number(x) do 
        raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x
    end
 	result = case x < 0  do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary}
  end

  def zge(virt_code, [x | data_stack], return_stack, dictionary) do	# вершина больше нуля
    if !is_number(x) do 
         raise ExecuterError, message: "not number", code: virt_code, stack: data_stack, dict: dictionary, name: x
    end
 	result = case x > 0  do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary}
  end

  def const_true(virt_code, data_stack, return_stack, dictionary) do
    {virt_code, [@c_true | data_stack], return_stack, dictionary}
  end

  def const_false(virt_code, data_stack, return_stack, dictionary) do
    {virt_code, [@c_false | data_stack], return_stack, dictionary}
  end

  def b_or(virt_code, [y, x | data_stack], return_stack, dictionary) do
    {virt_code, [Bitwise.bor(x, y) | data_stack], return_stack, dictionary}
  end

  def l_and(virt_code, [y, x | data_stack], return_stack, dictionary) do
    b = if is_truthly(x) and is_truthly(y) do
        @c_true
      else
        @c_false
      end

   {virt_code, [b | data_stack], return_stack, dictionary}
  end

  def l_or(virt_code, [y, x | data_stack], return_stack, dictionary) do
    b = if is_truthly(x) or is_truthly(y) do
        @c_true
      else
        @c_false
      end

    {virt_code, [b | data_stack], return_stack, dictionary}
  end

  def l_xor(virt_code, [y, x | data_stack], return_stack, dictionary) do
	double_x = is_truthly(x)
	double_y = is_truthly(y)
    b = !double_x && double_y || double_x && !double_y
	#IO.puts("b")
	#IO.inspect(b)
    {virt_code, [b | data_stack], return_stack, dictionary}
  end

  def l_not(virt_code, [x | data_stack], return_stack, dictionary) do	# изменение значение флага на противоположное
    b = if is_truthly(x) do
        @c_false
      else
        @c_true
      end
    {virt_code, [b | data_stack], return_stack, dictionary}
  end

  def b_shift_right(virt_code, [y, x | data_stack], return_stack, dictionary) do
    {virt_code, [Bitwise.bsr(x, y) | data_stack], return_stack, dictionary}
  end

  def b_shift_left(virt_code, [y, x | data_stack], return_stack, dictionary) do
    {virt_code, [Bitwise.bsl(x, y) | data_stack], return_stack, dictionary}
  end

  def b_xor(virt_code, [y, x | data_stack], return_stack, dictionary) do
    {virt_code, [Bitwise.bxor(x, y) | data_stack], return_stack, dictionary}
  end

  def b_not(virt_code, [x | data_stack], return_stack, dictionary) do	
    {virt_code, [Bitwise.bnot(x) | data_stack], return_stack, dictionary}
  end

  def b_and(virt_code, [y, x | data_stack], return_stack, dictionary) do
    {virt_code, [Bitwise.band(x, y) | data_stack], return_stack, dictionary}
  end

#-------------------
#  word of interprete
#-------------------
  def create([word_name | tokens], data_stack, return_stack, dictionary) do
    # Задание: интерпретировать  немедленно
    if Map.has_key?(dictionary,  word_name) do
      IO.write("переопределяется '#{word_name}'")
    end
    {word_tokens, [";" | tokens]} = Enum.split_while(tokens, fn s -> s != ";" end) 

 	{ tokens, data_stack, return_stack, add_word(dictionary,word_name, word_tokens)}
  end

  def exit(virt_code, data_stack, _return_stack, dictionary) do
    raise ExecuterError, message: "exit", code: virt_code, stack: data_stack, dict: dictionary
    #exit(:normal) # Process.exit(:normal) #! System.exit(0) #
    #{[], data_stack, return_stack, dictionary}
  end

  def abort(_virt_code, _data_stack, _return_stack, dictionary) do
    {[], [], [], dictionary}
  end

  def quit(_virt_code, data_stack, return_stack, dictionary) do
    {[], data_stack, return_stack,  dictionary}
  end

  def abort_msg(_virt_code, [ message | _data_stack], _return_stack, dictionary) do
	IO.write(message <> " ")
	 {[], [], [], dictionary}
  end

  def variable([word_name | tail], data_stack, return_stack, dictionary) do	# работает во время исполнения
    #IO.puts(word_name)
    #IO.inspect(dictionary)
    if Map.has_key?(dictionary, word_name) do
      IO.write("переопределяется '#{word_name}'")
    end
    dict = add_var(dictionary, word_name, :unknown)
    #IO.inspect(dict)
    {tail, data_stack, return_stack, dict} 
  end

  def set_variable(virt_code, [var_name, x | data_stack], return_stack, dictionary) do 
    #IO.puts(var_name)
	case set_var(dictionary, var_name, x) do
	  :error -> raise ExecuterError, message: "there's no declared variable", code: virt_code, stack: data_stack, dict: dictionary, name: var_name
	  dict	->  {virt_code, data_stack, return_stack, dict}
	end
  end

  def inc_variable(virt_code, [var_name, x | data_stack], return_stack, dictionary) do
	#IO.puts("inc_var #{var_name} #{x}")
	case get_var(dictionary, var_name) do
	  :unknown	-> 	raise ExecuterError, message: "undefined variable", code: virt_code, stack: data_stack, dict: dictionary, name: var_name
	  :error	->	raise ExecuterError, message: "there's no declared variable", code: virt_code, stack: data_stack, dict: dictionary, name: var_name
	  value		-> 	dict = set_var(dictionary, var_name, value + x) # что будет, если x и value не числа!?	
					{virt_code, data_stack, return_stack, dict}
	end
  end

  def get_variable(virt_code, [var_name | data_stack], return_stack, dictionary) do # перенёс на этап интерпретации
	case get_var(dictionary, var_name) do
	  :unknown	->  raise ExecuterError, message: "undefined variable", code: virt_code, stack: data_stack, dict: dictionary, name: var_name
	  :error    ->  raise ExecuterError, message: "there's no declared variable", code: virt_code, stack: data_stack, dict: dictionary, name: var_name
	  value	    ->  {virt_code, [value | data_stack], return_stack, dictionary}
	end   
  end

  def constant([const_name | virt_code],  data_stack, return_stack, dictionary) do
    if data_stack == [] do
         raise ExecuterError, message: "an empty stack", code: virt_code, stack: data_stack, dict: dictionary, name: const_name
    end
    [x | data_stack] = data_stack
    if Map.has_key?(dictionary, const_name) do
       raise ExecuterError, message: "there is no need constant", code: virt_code, stack: data_stack, dict: dictionary, name: const_name
    end
    {virt_code, data_stack, return_stack, add_const(dictionary, const_name, x)}
  end

  # в алгоритме не работает
  def get_const([const_name | virt_code], data_stack, return_stack, dictionary) do
	case get_const(dictionary, const_name) do
	  :error -> raise ExecuterError, message: "there is no declared constant", code: virt_code, stack: data_stack, dict: dictionary, name: const_name
	  value	->  {virt_code, [value | data_stack], return_stack, dictionary}
	end   
  end

#-------------------
#  word of IO
#-------------------
  def emit(virt_code, [c | data_stack], return_stack, dictionary) do
    IO.write(<<c>>)
    {
      virt_code, data_stack, return_stack, dictionary
    }
  end

  def cr(virt_code, data_stack, return_stack, dictionary) do
    IO.write( "\n" )
    {virt_code, data_stack, return_stack, dictionary}
  end

  def dot(virt_code, data_stack, return_stack, dictionary) do
	data_stack = case data_stack do
	  [] -> IO.write("стек пуст ")  # !!! перевести в кортеж 
			[]	
	  _  -> [x | tail] = data_stack
    		IO.write("#{x} ")
			tail
	end
    {virt_code, data_stack, return_stack, dictionary}
  end

  def dot_r(virt_code, [ width, value | data_stack], return_stack, dictionary) do
	string = case value do
	  value when is_integer(value) and  is_integer(width) ->  string = Integer.to_string(value)
														  	aligned_string(string, width)
	  value when is_float(value) and  is_integer(width) ->  string = Integer.to_string(value)
														  	aligned_string(string, width)
	  _ -> {:error, "ошибка параметров слова .R"}
	end
	IO.write(string)
    {virt_code, data_stack, return_stack, dictionary}
  end

  def dot_msg(virt_code, [message | data_stack], return_stack, dictionary) do
	 IO.write(message)
    {virt_code, data_stack, return_stack, dictionary}
  end

  def dump_data_stack(virt_code, data_stack, return_stack, dictionary) do
	#IO.puts("dump_data_stack")
	length = length(data_stack)
	IO.write("<#{length}> ")
    data_stack
    |> Enum.reverse()
    |> Enum.each(fn x -> IO.write("#{x} ") end)

    {virt_code, data_stack, return_stack, dictionary}
  end

  def dictionary(virt_code, data_stack, return_stack, dictionary) do
	IO.puts("dump_dictionary")
	length = map_size(dictionary)
	IO.puts("<#{length}> ")
    dictionary
    |> Enum.each(fn {k,v} ->    IO.write(k <> " => ")
                                IO.inspect(v) end)

    {virt_code, data_stack, return_stack, dictionary}
  end

  def space(virt_code, data_stack, return_stack, dictionary) do
    IO.write( " ")
    {virt_code, data_stack, return_stack, dictionary}
  end

  def spaces(virt_code, [amount |tail], return_stack, dictionary) do
    IO.write(String.duplicate(" ", amount))
    {virt_code, tail, return_stack, dictionary}
  end

  #-------------
  # flow control
  #-------------
  def do_word(virt_code, [count, end_count | data_stack], return_stack, dictionary) do
	#IO.puts(count)
	#IO.puts(end_count)

    { 
      virt_code, data_stack, [count, end_count, %{do: virt_code} | return_stack],
      dictionary
	}
  end

  def i(virt_code, data_stack, [count, _end_count, %{do: _do_tokens} | _] = return_stack,
        dictionary) do
    {
      virt_code, [count | data_stack], return_stack, dictionary
    }
  end

  def j(virt_code, data_stack, [_count, _end_count, %{do: _do_tokens}, data | _] = return_stack,
        dictionary) do
    {virt_code, [data | data_stack], return_stack, dictionary}
  end


  def copy_r_to_d(virt_code, data_stack, [data | _] = return_stack, dictionary) do
    {
	  virt_code, [data | data_stack], return_stack, dictionary
	}
  end

  def move_d_to_r(virt_code, [data | data_stack], return_stack, dictionary) do
    {
	  virt_code, data_stack, [data | return_stack], dictionary
	}
  end

  def move_r_to_d(virt_code, data_stack, [data | return_stack], dictionary) do
    {
	  virt_code, [data | data_stack], return_stack, dictionary
	}
  end

  def loop(virt_code, data_stack, [count, end_count, %{do: do_tokens} | return_stack], dictionary) do
    count = count + 1

    case count < end_count do
      true	->	{ do_tokens, data_stack, [count, end_count, %{do: do_tokens} | return_stack],
          dictionary}
      false ->	{ virt_code, data_stack, return_stack, dictionary }
    end
  end

  def plus_loop(virt_code, [inc | data_stack], [count, end_count, %{do: do_tokens} | return_stack],
        dictionary) do
    count = count + inc
	sign = inc / abs(inc)
    case sign * count < sign * (end_count - 1) do
      true ->
        { do_tokens, data_stack, [count, end_count, %{do: do_tokens} | return_stack],
          dictionary}
      false ->
        { virt_code, data_stack, return_stack, dictionary}
    end
  end

  def begin(virt_code, data_stack, return_stack, dictionary) do
      #IO.inspect(virt_code)
    { virt_code, data_stack, [%{begin: virt_code} | return_stack], dictionary  }
  end

  def until(virt_code,  [condition | data_stack], [%{begin: until_virt_code} | return_stack],
        dictionary) do
    # IO.puts(condition)
	# IO.inspect(virt_code)

    case is_falsely(condition) do
      true -> #IO.inspect(until_virt_code)
        {
          until_virt_code,
          data_stack,
          [%{begin: until_virt_code} | return_stack], dictionary
        }
      false -> #IO.inspect(virt_code)
        {
		  virt_code, data_stack, return_stack, dictionary
		}
    end
  end

  def while(virt_code,  [condition | data_stack], [%{begin: while_virt_code} | return_stack],
        dictionary) do
    #IO.puts(condition)
    #IO.inspect(virt_code)

    case is_falsely(condition) do
      false -> #IO.inspect(while_virt_code)
        {
          virt_code,
          data_stack,
          [%{begin: while_virt_code} | return_stack], dictionary
        }
      true -> 
        {_virt_code, [:repeat | behind_virt_code]} = Enum.split_while(virt_code, fn s -> s != :repeat end)

        { behind_virt_code, data_stack, return_stack, dictionary }
    end
  end

  def repeat(_virt_code,  data_stack, [%{begin: repeat_virt_code} | return_stack],
        dictionary) do

    { repeat_virt_code, data_stack, [%{begin: repeat_virt_code} | return_stack],
      dictionary
    }
  end


  def delay(virt_code, [delay | data_stack], return_stack, dictionary) do

    :timer.sleep(delay)

    { virt_code, data_stack, return_stack, dictionary}
  end

  # ---------------------------------------------
  # Stack operations
  # ---------------------------------------------
  def depth(virt_code, data_stack, return_stack, dictionary) do
    {virt_code, [length(data_stack) | data_stack], return_stack, dictionary}
  end

  def drop(virt_code, data_stack, return_stack, dictionary) do
	depth = length(data_stack)
	case depth do
	  0 -> 	raise ExecuterError, message: "an empty stack", code: virt_code, stack: data_stack, dict: dictionary 
	  _ ->	[_ | cut_stack] = data_stack
			{virt_code, cut_stack, return_stack, dictionary}
	end
  end

  def drop2(virt_code, [_, _ | data_stack], return_stack, dictionary) do
    {virt_code, data_stack, return_stack, dictionary}
  end

  def dup(virt_code, [x | data_stack], return_stack, dictionary) do
    {virt_code, [x, x | data_stack], return_stack, dictionary}
  end

  def dup2(virt_code, [x, y | data_stack], return_stack, dictionary) do
    {virt_code, [x, y, x, y | data_stack], return_stack, dictionary}
  end

  def dup?(virt_code, [x | _] = data_stack, return_stack, dictionary) when is_falsely(x) do
    {virt_code, data_stack, return_stack, dictionary}
  end

  def dup?(virt_code, [x | _] = data_stack, return_stack, dictionary) do
    {virt_code, [x | data_stack], return_stack, dictionary}
  end

  def swap(virt_code, [y, x | data_stack], return_stack, dictionary) do
    {virt_code, [x, y | data_stack], return_stack, dictionary}
  end

  def swap2(virt_code, [x1, y1, x2, y2 | data_stack], return_stack, dictionary) do
    {virt_code, [x2, y2, x1, y1 | data_stack], return_stack, dictionary}
  end

  def over(virt_code, [x, y | data_stack], return_stack, dictionary) do
    {virt_code, [y, x, y | data_stack], return_stack, dictionary}
  end

  def over2(virt_code, [x1, y1, x2, y2 | data_stack], return_stack, dictionary) do
    {virt_code, [x2, y2, x1, y1, x2, y2 | data_stack], return_stack, dictionary}
  end

  def rot(virt_code, [z, y, x | data_stack], return_stack, dictionary) do
    {virt_code, [x, z, y | data_stack], return_stack, dictionary}
  end

  def rot_neg(virt_code, [z, y, x | data_stack], return_stack, dictionary) do
    {virt_code, [y, x, z | data_stack], return_stack, dictionary}
  end

  # ---------------------------------------------
  # Date & time operations
  # ---------------------------------------------
  def time_and_date(virt_code, data_stack, return_stack, dictionary) do
    datetime = DateTime.utc_now(:millisecond)
    year    = datetime.year
    month   = datetime.month
    day     = datetime.day
    hour    = datetime.hour
    minute  = datetime.minute
    second  = datetime.second
    #IO.puts(second)
    {virt_code, [ second, minute, hour, day, month, year | data_stack], return_stack, dictionary}
  end
   
  def timestamp(virt_code, data_stack, return_stack, dictionary) do
    timestamp = DateTime.utc_now(:millisecond) |> DateTime.to_unix(:millisecond)
    {virt_code, [ timestamp | data_stack], return_stack, dictionary}
  end

  def to_timestamp(virt_code, [text | data_stack], return_stack, dictionary) do
    timestamp = NaiveDateTime.from_iso8601!(text)
    {virt_code, [ timestamp | data_stack], return_stack, dictionary}
  end

  def text_to_unix( virt_code, [ text | data_stack], return_stack, dictionary) do
    {:ok, dt} = NaiveDateTime.from_iso8601!(text) |> DateTime.from_naive("Etc/UTC")
    ts = DateTime.to_unix(dt, :millisecond)
    {virt_code, [ ts | data_stack], return_stack, dictionary}
  end

  def datatime_from_unix( virt_code, [milliseconds | data_stack], return_stack, dictionary) do
    {:ok, datetime} = DateTime.from_unix(milliseconds, :millisecond)
    {virt_code, [ datetime | data_stack], return_stack, dictionary}
  end

  def datatime_to_unix( virt_code, [datatime | data_stack], return_stack, dictionary) do
    timestamp = DateTime.to_unix(datatime, :millisecond)
    {virt_code, [ timestamp | data_stack], return_stack, dictionary}
  end
  

  # ---------------------------------------------
  # server operations
  # ---------------------------------------------
  def start_next(virt_code, [ word | data_stack], return_stack, dictionary) do
    slf = self()
    #Enum.each(stocks, fn name ->
    #   ForthIbE.Monad.execute(name, word)  # только монады напрямую запускаются?
    #end)
    send(slf, {:start_next, slf, word} )
    {virt_code,  data_stack, return_stack, dictionary}
  end

  def receive_time(virt_code, data_stack, return_stack, dictionary) do
    {:tick, ts, :sys_timer} = SysTimer.get_sys_time
    {virt_code,  [ts | data_stack], return_stack, dictionary}
  end

  def avost!(virt_code, data_stack, return_stack, dictionary) do
    #IO.puts("В АВОСТ")
    avost = receive do
      {:avost} -> #IO.puts("Поймал АВОСТ")
                  -1
    after
      0        -> #IO.puts("Нет АВОСТа")
                  0
    end
    {virt_code,  [avost | data_stack], return_stack, dictionary}
  end

  def forward(virt_code, data_stack, return_stack, dictionary) do #!!! 
    #IO.inspect(where)
    #IO.inspect(data_stack)
    mail = data_stack |> Enum.reverse |> List.to_tuple 
    where = case ForthIbE.Dictionary.get_var(dictionary, "_STOCKS") do
      :error -> raise ExecuterError, message: "not var", code: virt_code, stack: data_stack, dict: dictionary, name: "_STOCKS"
      value  -> value
    end
    Enum.each(where, fn name ->
                    send(name, mail) end
    )
    {virt_code,  [], return_stack, dictionary}
  end

  # ---------------------------------------------
  # help operations
  # ---------------------------------------------
  def to_atom(virt_code, [string | data_stack], return_stack, dictionary) do
    atom = String.to_atom(string)
    #IO.inspect(atom)
    {virt_code, [ atom | data_stack], return_stack, dictionary}
  end

  def to_list(virt_code, data_stack, return_stack, dictionary) do
    list =  Enum.each(data_stack, fn str ->
                String.to_atom(str)
    end)
    {virt_code, [list | data_stack], return_stack, dictionary}
  end
end

