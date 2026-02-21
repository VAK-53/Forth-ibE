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
  def plus(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
     {virt_code, [x + y | data_stack], return_stack, dictionary, stocks}
  end

  def minus(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
     {virt_code, [x - y | data_stack], return_stack, dictionary, stocks}
  end

  def mult(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
    #IO.puts("in mult")
    {virt_code, [x * y | data_stack], return_stack, dictionary, stocks}
  end

  def div(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
    #IO.inspect(virt_code)
	case y do
	  0 -> 	{:error, " ошибочное деление на 0"}
      _ -> 	{virt_code, [x / y | data_stack], return_stack, dictionary, stocks}
	end
  end

  def mod(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
    #IO.write("#{y} #{x}")
    {virt_code, [ rem(x, y) | data_stack], return_stack, dictionary, stocks}
  end

  def div_mod(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [div(x, y), rem(x, y) | data_stack], return_stack, dictionary, stocks}
  end

  def pow(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [:math.pow(x, y) | data_stack], return_stack, dictionary, stocks}
  end

  def mult_div(virt_code, [x, y, z | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [x*y/z| data_stack], return_stack, dictionary, stocks}
  end

  def one_plus(virt_code, [x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [x + 1 | data_stack], return_stack, dictionary, stocks}
  end

  def one_minus(virt_code, [x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [x - 1 | data_stack], return_stack, dictionary, stocks}
  end

  def two_mult(virt_code, [x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [2 * x | data_stack], return_stack, dictionary, stocks}
  end

  def two_div(virt_code, [x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [ x / 2 | data_stack], return_stack, dictionary, stocks}
  end

  def negate(virt_code, [x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [-x | data_stack], return_stack, dictionary, stocks}
  end

  def forth_abs(virt_code, [x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [abs(x) | data_stack], return_stack, dictionary, stocks}
  end

  def rand(virt_code, data_stack, return_stack, dictionary, stocks) do
    {virt_code, [:rand.uniform() | data_stack], return_stack, dictionary, stocks}
  end

  def min(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [min(x, y) | data_stack], return_stack, dictionary, stocks}
  end

  def max(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [max(x, y) | data_stack], return_stack, dictionary, stocks}
  end

  def sqrt(virt_code, [x | data_stack], return_stack, dictionary, stocks) do
	case x do
	  x when x < 0 -> 	{:error, " отрицательное подкоренное значение"}
      _ -> 	{virt_code, [:math.sqrt(x) | data_stack], return_stack, dictionary, stocks}
	end  
  end

  def sin(virt_code, [x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [:math.sin(x) | data_stack], return_stack, dictionary, stocks}
  end

  def cos(virt_code, [x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [:math.cos(x) | data_stack], return_stack, dictionary, stocks}
  end

  def tan(virt_code, [x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [:math.tan(x) | data_stack], return_stack, dictionary, stocks}
  end

  def pi(virt_code, data_stack, return_stack, dictionary, stocks) do
    {virt_code, [:math.pi()| data_stack], return_stack, dictionary, stocks}
  end

  # logic
  @c_true -1 #true
  @c_false 0 #false

  #defguard is_falsely(value) when value == false or value == nil or value == 0 or value == ""
  #defguard is_truthly(value) when not is_falsely(value)

  def eq(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do	# равенство двух элементов
	result = case x == y do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [ result | data_stack], return_stack, dictionary, stocks}
  end

  def zeq(virt_code, [x | data_stack], return_stack, dictionary, stocks) do	# вершина равена нулю
	result = case x == 0 do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary, stocks}
  end

  def neq(virt_code, [ y, x | data_stack], return_stack, dictionary, stocks) do	# отрицание элемента
    {virt_code, [x != y| data_stack], return_stack, dictionary, stocks}
  end

  def lt(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do	# вершина меньше второго элемента
	result = case x < y do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary, stocks}
  end

  def lte(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do	# вершина меньше или равна второму элементу
	result = case x <= y do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary, stocks}
  end

  def gt(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do	# вершина больше второго элемента
 	result = case x > y  do
	  true 	-> @c_true
	  false	-> @c_false
	end
   {virt_code, [result | data_stack], return_stack, dictionary, stocks}
  end

  def gte(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do	# вершина больше или равна второму элементу
 	result = case x >= y  do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary, stocks}
  end

  def zle(virt_code, [x | data_stack], return_stack, dictionary, stocks) do	# вершина меньше нуля
 	result = case x < 0  do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary, stocks}
  end

  def zge(virt_code, [x | data_stack], return_stack, dictionary, stocks) do	# вершина больше нуля
 	result = case x > 0  do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary, stocks}
  end

  def const_true(virt_code, data_stack, return_stack, dictionary, stocks) do
    {virt_code, [@c_true | data_stack], return_stack, dictionary, stocks}
  end

  def const_false(virt_code, data_stack, return_stack, dictionary, stocks) do
    {virt_code, [@c_false | data_stack], return_stack, dictionary, stocks}
  end

  def b_or(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [Bitwise.bor(x, y) | data_stack], return_stack, dictionary, stocks}
  end

  def l_and(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
    b = if is_truthly(x) and is_truthly(y) do
        @c_true
      else
        @c_false
      end

   {virt_code, [b | data_stack], return_stack, dictionary, stocks}
  end

  def l_or(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
    b = if is_truthly(x) or is_truthly(y) do
        @c_true
      else
        @c_false
      end

    {virt_code, [b | data_stack], return_stack, dictionary, stocks}
  end

  def l_xor(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
	double_x = is_truthly(x)
	double_y = is_truthly(y)
    b = !double_x && double_y || double_x && !double_y
	#IO.puts("b")
	#IO.inspect(b)
    {virt_code, [b | data_stack], return_stack, dictionary, stocks}
  end

  def l_not(virt_code, [x | data_stack], return_stack, dictionary, stocks) do	# изменение значение флага на противоположное
    b = if is_truthly(x) do
        @c_false
      else
        @c_true
      end
    {virt_code, [b | data_stack], return_stack, dictionary, stocks}
  end

  def b_shift_right(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [Bitwise.bsr(x, y) | data_stack], return_stack, dictionary, stocks}
  end

  def b_shift_left(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [Bitwise.bsl(x, y) | data_stack], return_stack, dictionary, stocks}
  end

  def b_xor(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [Bitwise.bxor(x, y) | data_stack], return_stack, dictionary, stocks}
  end

  def b_not(virt_code, [x | data_stack], return_stack, dictionary, stocks) do	
    {virt_code, [Bitwise.bnot(x) | data_stack], return_stack, dictionary, stocks}
  end

  def b_and(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [Bitwise.band(x, y) | data_stack], return_stack, dictionary, stocks}
  end

#-------------------
#  word of interprete
#-------------------
  def create([word_name | tokens], data_stack, return_stack, dictionary, stocks) do
    # Задание: интерпретировать  немедленно
    if Map.has_key?(dictionary,  word_name) do
      IO.write("переопределяется '#{word_name}'")
    end
    {word_tokens, [";" | tokens]} = Enum.split_while(tokens, fn s -> s != ";" end) 

 	{ tokens, data_stack, return_stack, add_word(dictionary,word_name, word_tokens), stocks}
  end

  def exit(_virt_code, data_stack, return_stack, dictionary, stocks) do
    exit(:normal) # Process.exit(:normal) #! System.exit(0) #
    {[], data_stack, return_stack, dictionary, stocks}
  end

  def abort(_virt_code, _data_stack, _return_stack, dictionary, stocks) do
    {[], [], [], dictionary, stocks}
  end

  def quit(_virt_code, data_stack, return_stack, dictionary, stocks) do
    {[], data_stack, return_stack,  dictionary, stocks}
  end

  def abort_msg(_virt_code, [ message | _data_stack], _return_stack, dictionary, stocks) do
	IO.write(message <> " ")
	 {[], [], [], dictionary, stocks}
  end

  def variable([word_name | tail], data_stack, return_stack, dictionary, stocks) do	# работает во время исполнения
    #IO.puts(word_name)
    #IO.inspect(dictionary)
    if Map.has_key?(dictionary, word_name) do
      IO.write("переопределяется '#{word_name}'")
    end
    dict = add_var(dictionary, word_name, :unknown)
    #IO.inspect(dict)
    {tail, data_stack, return_stack, dict, stocks} 
  end

  def set_variable(virt_code, [ var_name, x | data_stack], return_stack, dictionary, stocks) do 
    #IO.puts(var_name)
	case set_var(dictionary, var_name, x) do
	  :error -> {:error, "в словаре отсутствует объявленная переменная #{var_name} "}
	  dict	->  # IO.puts("установили переменную")
                IO.inspect(dict)
                {virt_code, data_stack, return_stack, dict, stocks}
	end
  end

  def inc_variable(virt_code, [word_name, x | data_stack], return_stack, dictionary, stocks) do
	# IO.puts("inc_var #{word_name} #{x}")
	case get_var(dictionary, word_name) do
	  :unknown	-> 	{:error, "переменная #{word_name} содержит неопределенное значение"}
	  :error	->	{:error, "в словаре отсутствует объявленная переменная #{word_name} "}
	  value		-> 	dict = set_var(dictionary, word_name, value + x) # что будет, если x и value не числа!?	
					{virt_code, data_stack, return_stack, dict, stocks}
	end
  end

  def get_variable(virt_code, [word_name | data_stack], return_stack, dictionary, stocks) do # перенёс на этап интерпретации
	case get_var(dictionary, word_name) do
	  :error -> {:error, "в словаре отсутствует объявленная переменная #{word_name} "}
	  value	->  #IO.puts(value)
                {virt_code, [value | data_stack], return_stack, dictionary, stocks}
	end   
  end

  def constant([word_name | virt_code], [x | data_stack], return_stack, dictionary, stocks) do
    if Map.has_key?(dictionary, word_name) do
      IO.write("переопределяется '#{word_name}' со значением '#{inspect(x)}'")
    end
    {virt_code, data_stack, return_stack, add_const(dictionary, word_name, x), stocks}
  end

  # в алгоритме не работает
  def get_const([const_name | virt_code], data_stack, return_stack, dictionary, stocks) do
	case get_const(dictionary, const_name) do
	  :error -> {:error, "в словаре отсутствует объявленная константа #{const_name} "}
	  value	->  {virt_code, [value | data_stack], return_stack, dictionary, stocks}
	end   
  end


#-------------------
#  word of IO
#-------------------
  def emit(virt_code, [c | data_stack], return_stack, dictionary, stocks) do
    IO.write(<<c>>)
    {
      virt_code, data_stack, return_stack, dictionary, stocks
    }
  end

  def cr(virt_code, data_stack, return_stack, dictionary, stocks) do
    IO.write( "\n" )
    {virt_code, data_stack, return_stack, dictionary, stocks}
  end

  def dot(virt_code, data_stack, return_stack, dictionary, stocks) do
	data_stack = case data_stack do
	  [] -> IO.write("стек пуст ")  # !!! перевести в кортеж 
			[]	
	  _  -> [x | tail] = data_stack
    		IO.write("#{x} ")
			tail
	end
    {virt_code, data_stack, return_stack, dictionary, stocks}
  end

  def dot_r(virt_code, [ width, value | data_stack], return_stack, dictionary, stocks) do
	string = case value do
	  value when is_integer(value) and  is_integer(width) ->  string = Integer.to_string(value)
														  	aligned_string(string, width)
	  value when is_float(value) and  is_integer(width) ->  string = Integer.to_string(value)
														  	aligned_string(string, width)
	  _ -> {:error, "ошибка параметров слова .R"}
	end
	IO.write(string)
    {virt_code, data_stack, return_stack, dictionary, stocks}
  end

  def dot_msg(virt_code, [message | data_stack], return_stack, dictionary, stocks) do
	 IO.write(message)
    {virt_code, data_stack, return_stack, dictionary, stocks}
  end

  def dump_data_stack(virt_code, data_stack, return_stack, dictionary, stocks) do
	#IO.puts("dump_data_stack")
	length = length(data_stack)
	IO.write("<#{length}> ")
    data_stack
    |> Enum.reverse()
    |> Enum.each(fn x -> IO.write("#{x} ") end)

    {virt_code, data_stack, return_stack, dictionary, stocks}
  end

  def dictionary(virt_code, data_stack, return_stack, dictionary, stocks) do
	IO.puts("dump_dictionary")
	length = map_size(dictionary)
	IO.puts("<#{length}> ")
    dictionary
    |> Enum.each(fn {k,v} ->    IO.write(k <> " => ")
                                IO.inspect(v) end)

    {virt_code, data_stack, return_stack, dictionary, stocks}
  end

  def space(virt_code, data_stack, return_stack, dictionary, stocks) do
    IO.write( " ")
    {virt_code, data_stack, return_stack, dictionary, stocks}
  end

  def spaces(virt_code, [amount |tail], return_stack, dictionary, stocks) do
    IO.write(String.duplicate(" ", amount))
    {virt_code, tail, return_stack, dictionary, stocks}
  end

  #-------------
  # flow control
  #-------------
  def do_word(virt_code, [count, end_count | data_stack], return_stack, dictionary, stocks) do
	#IO.puts(count)
	#IO.puts(end_count)

    { 
      virt_code, data_stack, [count, end_count, %{do: virt_code} | return_stack],
      dictionary, stocks
	}
  end

  def i(virt_code, data_stack, [count, _end_count, %{do: _do_tokens} | _] = return_stack,
        dictionary, stocks) do
    {
      virt_code, [count | data_stack], return_stack, dictionary, stocks
    }
  end

  def j(virt_code, data_stack, [_count, _end_count, %{do: _do_tokens}, data | _] = return_stack,
        dictionary, stocks) do
    {virt_code, [data | data_stack], return_stack, dictionary, stocks}
  end


  def copy_r_to_d(virt_code, data_stack, [data | _] = return_stack, dictionary, stocks) do
    {
	  virt_code, [data | data_stack], return_stack, dictionary, stocks
	}
  end

  def move_d_to_r(virt_code, [data | data_stack], return_stack, dictionary, stocks) do
    {
	  virt_code, data_stack, [data | return_stack], dictionary, stocks
	}
  end

  def move_r_to_d(virt_code, data_stack, [data | return_stack], dictionary, stocks) do
    {
	  virt_code, [data | data_stack], return_stack, dictionary, stocks
	}
  end

  def loop(virt_code, data_stack, [count, end_count, %{do: do_tokens} | return_stack], dictionary, stocks) do
    count = count + 1

    case count < end_count do
      true	->	{ do_tokens, data_stack, [count, end_count, %{do: do_tokens} | return_stack],
          dictionary, stocks}
      false ->	{ virt_code, data_stack, return_stack, dictionary, stocks }
    end
  end

  def plus_loop(virt_code, [inc | data_stack], [count, end_count, %{do: do_tokens} | return_stack],
        dictionary, stocks) do
    count = count + inc
	sign = inc / abs(inc)
    case sign * count < sign * (end_count - 1) do
      true ->
        { do_tokens, data_stack, [count, end_count, %{do: do_tokens} | return_stack],
          dictionary, stocks}
      false ->
        { virt_code, data_stack, return_stack, dictionary, stocks}
    end
  end

  def begin(virt_code, data_stack, return_stack, dictionary, stocks) do
      #IO.inspect(virt_code)
    { virt_code, data_stack, [%{begin: virt_code} | return_stack], dictionary, stocks  }
  end

  def until(virt_code,  [condition | data_stack], [%{begin: until_virt_code} | return_stack],
        dictionary, stocks) do
    # IO.puts(condition)
	# IO.inspect(virt_code)

    case is_falsely(condition) do
      true -> #IO.inspect(until_virt_code)
        {
          until_virt_code,
          data_stack,
          [%{begin: until_virt_code} | return_stack], dictionary, stocks
        }
      false -> #IO.inspect(virt_code)
        {
		  virt_code, data_stack, return_stack, dictionary, stocks
		}
    end
  end

  def while(virt_code,  [condition | data_stack], [%{begin: while_virt_code} | return_stack],
        dictionary, stocks) do
    #IO.puts(condition)
    #IO.inspect(virt_code)

    case is_falsely(condition) do
      false -> #IO.inspect(while_virt_code)
        {
          virt_code,
          data_stack,
          [%{begin: while_virt_code} | return_stack],
          dictionary, stocks
        }
      true -> 
        {_virt_code, [:repeat | behind_virt_code]} = Enum.split_while(virt_code, fn s -> s != :repeat end)
        #IO.inspect(while_virt_code)
        {
		  behind_virt_code, data_stack, return_stack, dictionary, stocks
		}
    end
  end

  def repeat(_virt_code,  data_stack, [%{begin: repeat_virt_code} | return_stack],
        dictionary, stocks) do
    #IO.puts("repeat")
    #IO.inspect(virt_code)

    {
      repeat_virt_code, data_stack, [%{begin: repeat_virt_code} | return_stack],
      dictionary, stocks
    }
  end


  def delay(virt_code, [delay | data_stack], return_stack, dictionary, stocks) do

    :timer.sleep(delay)

    { virt_code, data_stack, return_stack, dictionary, stocks}
  end

  # ---------------------------------------------
  # Stack operations
  # ---------------------------------------------
  def depth(virt_code, data_stack, return_stack, dictionary, stocks) do
    {virt_code, [length(data_stack) | data_stack], return_stack, dictionary, stocks}
  end

  def drop(virt_code, data_stack, return_stack, dictionary, stocks) do
	depth = length(data_stack)
	case depth do
	  0 -> 	{:error, "drop пустого стека\n"}
	  _ ->	[_ | cut_stack] = data_stack
			{virt_code, cut_stack, return_stack, dictionary, stocks}
	end
  end

  def drop2(virt_code, [_, _ | data_stack], return_stack, dictionary, stocks) do
    {virt_code, data_stack, return_stack, dictionary, stocks}
  end

  def dup(virt_code, [x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [x, x | data_stack], return_stack, dictionary, stocks}
  end

  def dup2(virt_code, [x, y | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [x, y, x, y | data_stack], return_stack, dictionary, stocks}
  end

  def dup?(virt_code, [x | _] = data_stack, return_stack, dictionary, stocks) when is_falsely(x) do
    {virt_code, data_stack, return_stack, dictionary, stocks}
  end

  def dup?(virt_code, [x | _] = data_stack, return_stack, dictionary, stocks) do
    {virt_code, [x | data_stack], return_stack, dictionary, stocks}
  end

  def swap(virt_code, [y, x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [x, y | data_stack], return_stack, dictionary, stocks}
  end

  def swap2(virt_code, [x1, y1, x2, y2 | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [x2, y2, x1, y1 | data_stack], return_stack, dictionary, stocks}
  end

  def over(virt_code, [x, y | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [y, x, y | data_stack], return_stack, dictionary, stocks}
  end

  def over2(virt_code, [x1, y1, x2, y2 | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [x2, y2, x1, y1, x2, y2 | data_stack], return_stack, dictionary, stocks}
  end

  def rot(virt_code, [z, y, x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [x, z, y | data_stack], return_stack, dictionary, stocks}
  end

  def rot_neg(virt_code, [z, y, x | data_stack], return_stack, dictionary, stocks) do
    {virt_code, [y, x, z | data_stack], return_stack, dictionary, stocks}
  end

  # ---------------------------------------------
  # Date & time operations
  # ---------------------------------------------
  def time_and_date(virt_code, data_stack, return_stack, dictionary, stocks) do
    datetime = DateTime.utc_now(:millisecond)
    year    = datetime.year
    month   = datetime.month
    day     = datetime.day
    hour    = datetime.hour
    minute  = datetime.minute
    second  = datetime.second
    #IO.puts(second)
    {virt_code, [ second, minute, hour, day, month, year | data_stack], return_stack, dictionary, stocks}
  end
   
  def timestamp(virt_code, data_stack, return_stack, dictionary, stocks) do
    timestamp = DateTime.utc_now(:millisecond) |> DateTime.to_unix(:millisecond)
    {virt_code, [ timestamp | data_stack], return_stack, dictionary, stocks}
  end

  def to_timestamp(virt_code, [text | data_stack], return_stack, dictionary, stocks) do
    timestamp = NaiveDateTime.from_iso8601!(text)
    {virt_code, [ timestamp | data_stack], return_stack, dictionary, stocks}
  end

  def text_to_unix( virt_code, [ text | data_stack], return_stack, dictionary, stocks) do
    {:ok, dt} = NaiveDateTime.from_iso8601!(text) |> DateTime.from_naive("Etc/UTC")
    ts = DateTime.to_unix(dt, :millisecond)
    {virt_code, [ ts | data_stack], return_stack, dictionary, stocks}
  end

  def datatime_from_unix( virt_code, [milliseconds | data_stack], return_stack, dictionary, stocks) do
    {:ok, datetime} = DateTime.from_unix(milliseconds, :millisecond)
    {virt_code, [ datetime | data_stack], return_stack, dictionary, stocks}
  end

  def datatime_to_unix( virt_code, [datatime | data_stack], return_stack, dictionary, stocks) do
    timestamp = DateTime.to_unix(datatime, :millisecond)
    {virt_code, [ timestamp | data_stack], return_stack, dictionary, stocks}
  end
  

  # ---------------------------------------------
  # server operations
  # ---------------------------------------------
  def pass_next(virt_code, [ word | data_stack], return_stack, dictionary, stocks) do
    #IO.inspect(stocks) 
    Enum.each(stocks, fn name ->
       ForthIbE.execute(name, word)
    end)
    {virt_code,  data_stack, return_stack, dictionary, stocks}
  end

  def receive_time(virt_code, data_stack, return_stack, dictionary, stocks) do
    {:tick, ts, :sys_timer} = SysTimer.get_sys_time
    {virt_code,  [ts | data_stack], return_stack, dictionary, stocks}
  end

  def avost!(virt_code, data_stack, return_stack, dictionary, stocks) do
    #IO.puts("В АВОСТ")
    avost = receive do
      {:avost} -> #IO.puts("Поймал АВОСТ")
                  -1
    after
      0 -> 0
    end
    {virt_code,  [avost | data_stack], return_stack, dictionary, stocks}
  end

  def forward(virt_code, [where | data_stack], return_stack, dictionary, stocks) do #!!! 
    #IO.inspect(where)
    #IO.inspect(data_stack)
    mail = data_stack |> Enum.reverse |> List.to_tuple 
    Enum.each(where, fn name ->
      send(name, mail)
    end)
    {virt_code,  [], return_stack, dictionary, stocks}
  end

  # ---------------------------------------------
  # help operations
  # ---------------------------------------------
  def to_atom(virt_code, [string | data_stack], return_stack, dictionary, stocks) do
    atom = String.to_atom(string)
    #IO.inspect(atom)
    {virt_code, [ atom | data_stack], return_stack, dictionary, stocks}
  end

  def to_list(virt_code, data_stack, return_stack, dictionary, stocks) do
    list =  Enum.each(data_stack, fn str ->
                String.to_atom(str)
    end)
    {virt_code, [list | data_stack], return_stack, dictionary, stocks}
  end

  def stocks(virt_code, data_stack, return_stack, dictionary, stocks) do
    #IO.inspect(stocks)
    {   
      virt_code, [stocks | data_stack], return_stack, dictionary, stocks
    }
  end

  def delete_stock(virt_code, [atom | data_stack], return_stack, dictionary, stocks) do
    new_stocks =  List.delete(stocks, atom)
    {
      virt_code, data_stack, return_stack, dictionary, new_stocks
    }
  end
end

