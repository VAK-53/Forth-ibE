defmodule ForthIbE.Words do
  @moduledoc """
  Встроенные функции поддержки слов
  """
  import ForthIbE.Dictionary
  import ForthIbE.Utils

  #----------
  # math
  #----------
  def plus(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
     {virt_code, [x + y | data_stack], return_stack, dictionary, recipients}
  end

  def minus(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
     {virt_code, [x - y | data_stack], return_stack, dictionary, recipients}
  end

  def mult(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [x * y | data_stack], return_stack, dictionary, recipients}
  end

  def div(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
	case y do
	  0 -> 	{:error, " ошибочное деление на 0"}
      _ -> 	{virt_code, [x / y | data_stack], return_stack, dictionary, recipients}
	end
  end

  def mod(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [ rem(x, y) | data_stack], return_stack, dictionary, recipients}
  end

  def div_mod(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [div(x, y), rem(x, y) | data_stack], return_stack, dictionary, recipients}
  end

  def pow(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [:math.pow(x, y) | data_stack], return_stack, dictionary, recipients}
  end

  def mult_div(virt_code, [x, y, z | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [x*y/z| data_stack], return_stack, dictionary, recipients}
  end

  def one_plus(virt_code, [x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [x + 1 | data_stack], return_stack, dictionary, recipients}
  end

  def one_minus(virt_code, [x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [x - 1 | data_stack], return_stack, dictionary, recipients}
  end

  def two_mult(virt_code, [x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [2 * x | data_stack], return_stack, dictionary, recipients}
  end

  def two_div(virt_code, [x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [ x / 2 | data_stack], return_stack, dictionary, recipients}
  end

  def negate(virt_code, [x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [-x | data_stack], return_stack, dictionary, recipients}
  end

  def forth_abs(virt_code, [x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [abs(x) | data_stack], return_stack, dictionary, recipients}
  end

  def rand(virt_code, data_stack, return_stack, dictionary, recipients) do
    {virt_code, [:rand.uniform() | data_stack], return_stack, dictionary, recipients}
  end

  def min(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [min(x, y) | data_stack], return_stack, dictionary, recipients}
  end

  def max(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [max(x, y) | data_stack], return_stack, dictionary, recipients}
  end

  def sqrt(virt_code, [x | data_stack], return_stack, dictionary, recipients) do
	case x do
	  x when x < 0 -> 	{:error, " отрицательное подкоренное значение"}
      _ -> 	{virt_code, [:math.sqrt(x) | data_stack], return_stack, dictionary, recipients}
	end  
  end

  def sin(virt_code, [x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [:math.sin(x) | data_stack], return_stack, dictionary, recipients}
  end

  def cos(virt_code, [x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [:math.cos(x) | data_stack], return_stack, dictionary, recipients}
  end

  def tan(virt_code, [x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [:math.tan(x) | data_stack], return_stack, dictionary, recipients}
  end

  def pi(virt_code, data_stack, return_stack, dictionary, recipients) do
    {virt_code, [:math.pi()| data_stack], return_stack, dictionary, recipients}
  end

  # logic
  @c_true -1 #true
  @c_false 0 #false

  defguard is_falsely(value) when value == false or value == nil or value == 0 or value == ""
  defguard is_truthly(value) when not is_falsely(value)

  def eq(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do	# равенство двух элементов
	result = case x == y do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [ result | data_stack], return_stack, dictionary, recipients}
  end

  def zeq(virt_code, [x | data_stack], return_stack, dictionary, recipients) do	# вершина равена нулю
	result = case x == 0 do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary, recipients}
  end

  def neq(virt_code, [ y, x | data_stack], return_stack, dictionary, recipients) do	# отрицание элемента
    {virt_code, [x != y| data_stack], return_stack, dictionary, recipients}
  end

  def lt(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do	# вершина меньше второго элемента
	result = case x < y do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary, recipients}
  end

  def lte(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do	# вершина меньше или равна второму элементу
	result = case x <= y do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary, recipients}
  end

  def gt(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do	# вершина больше второго элемента
 	result = case x > y  do
	  true 	-> @c_true
	  false	-> @c_false
	end
   {virt_code, [result | data_stack], return_stack, dictionary, recipients}
  end

  def gte(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do	# вершина больше или равна второму элементу
 	result = case x >= y  do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary, recipients}
  end

  def zle(virt_code, [x | data_stack], return_stack, dictionary, recipients) do	# вершина меньше нуля
 	result = case x < 0  do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary, recipients}
  end

  def zge(virt_code, [x | data_stack], return_stack, dictionary, recipients) do	# вершина больше нуля
 	result = case x > 0  do
	  true 	-> @c_true
	  false	-> @c_false
	end
    {virt_code, [result | data_stack], return_stack, dictionary, recipients}
  end

  def const_true(virt_code, data_stack, return_stack, dictionary, recipients) do
    {virt_code, [@c_true | data_stack], return_stack, dictionary, recipients}
  end

  def const_false(virt_code, data_stack, return_stack, dictionary, recipients) do
    {virt_code, [@c_false | data_stack], return_stack, dictionary, recipients}
  end

  def b_or(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [Bitwise.bor(x, y) | data_stack], return_stack, dictionary, recipients}
  end

  def l_and(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
    b = if is_truthly(x) and is_truthly(y) do
        @c_true
      else
        @c_false
      end

   {virt_code, [b | data_stack], return_stack, dictionary, recipients}
  end

  def l_or(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
    b = if is_truthly(x) or is_truthly(y) do
        @c_true
      else
        @c_false
      end

    {virt_code, [b | data_stack], return_stack, dictionary, recipients}
  end

  def l_xor(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
	double_x = is_truthly(x)
	double_y = is_truthly(y)
    b = !double_x && double_y || double_x && !double_y
	IO.puts("b")
	IO.inspect(b)
    {virt_code, [b | data_stack], return_stack, dictionary, recipients}
  end

  def l_not(virt_code, [x | data_stack], return_stack, dictionary, recipients) do	# изменение значение флага на противоположное
    b = if is_truthly(x) do
        @c_false
      else
        @c_true
      end

    {virt_code, [b | data_stack], return_stack, dictionary, recipients}
  end

  def b_shift_right(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [Bitwise.bsr(x, y) | data_stack], return_stack, dictionary, recipients}
  end

  def b_shift_left(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [Bitwise.bsl(x, y) | data_stack], return_stack, dictionary, recipients}
  end

  def b_xor(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [Bitwise.bxor(x, y) | data_stack], return_stack, dictionary, recipients}
  end

  def b_not(virt_code, [x | data_stack], return_stack, dictionary, recipients) do	
    {virt_code, [Bitwise.bnot(x) | data_stack], return_stack, dictionary, recipients}
  end

  def b_and(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [Bitwise.band(x, y) | data_stack], return_stack, dictionary, recipients}
  end

#-------------------
#  word of interpret
#-------------------
  def create([word_name | tokens], data_stack, return_stack, dictionary, recipients) do
    # Задание: интерпретировать  немедленно
    if Map.has_key?(dictionary, word_name) do
      IO.write("переопределяется '#{word_name}'")
    end
    {word_tokens, [";" | tokens]} = Enum.split_while(tokens, fn s -> s != ";" end) 

 	{ tokens, data_stack, return_stack, add_word(dictionary, word_name, word_tokens), recipients}
  end

  def exit(_virt_code, data_stack, return_stack, dictionary, recipients) do
    exit(:normal) # Process.exit(:normal) #! System.exit(0) #
    {[], data_stack, return_stack, dictionary, recipients}
  end

  def abort(_virt_code, _data_stack, _return_stack, dictionary, recipients) do
    {[], [], [], dictionary, recipients}
  end

  def quit(_virt_code, data_stack, return_stack, dictionary, recipients) do
    {[], data_stack, return_stack,  dictionary, recipients}
  end

  def abort_msg(_virt_code, [ message | _data_stack], _return_stack, dictionary, recipients) do
	IO.write(message <> " ")
	 {[], [], [], dictionary, recipients}
  end

  def variable([word_name | tail], data_stack, return_stack, dictionary, recipients) do	# работает во время исполнения
    if Map.has_key?(dictionary, word_name) do
      IO.write("переопределяется '#{word_name}'")
    end
    dictionary = add_var(dictionary, word_name, :unknown)
    {tail, data_stack, return_stack, dictionary, recipients} 
  end

  def set_variable(virt_code, [ word_name, x | data_stack], return_stack, dictionary, recipients) do !!! 
	case set_var(dictionary, word_name, x) do
	  :error -> {:error, "в словаре отсутствует объявленная переменная #{word_name} "}
	  dict	->  {virt_code, data_stack, return_stack, dict, recipients}
	end
  end

  def inc_variable(virt_code, [word_name, x | data_stack], return_stack, dictionary, recipients) do
	# IO.puts("inc_var #{word_name} #{x}")
	case get_var(dictionary, word_name) do
	  :unknown	-> 	{:error, "переменная #{word_name} содержит неопределенное значение"}
	  :error	->	{:error, "в словаре отсутствует объявленная переменная #{word_name} "}
	  value		-> 	dict = set_var(dictionary, word_name, value + x) # что будет, если x и value не числа!?	
					{virt_code, data_stack, return_stack, dict, recipients}
	end
  end

  def get_variable(virt_code, [word_name | data_stack], return_stack, dictionary, recipients) do
	case get_var(dictionary, word_name) do
	  :error -> {:error, "в словаре отсутствует объявленная переменная #{word_name} "}
	  value	->  {virt_code, [value | data_stack], return_stack, dictionary, recipients}
	end   
  end

  def constant([word_name | virt_code], [x | data_stack], return_stack, dictionary, recipients) do
    if Map.has_key?(dictionary, word_name) do
      IO.write("переопределяется '#{word_name}' со значением '#{inspect(x)}'")
    end
    {virt_code, data_stack, return_stack, add_const(dictionary, word_name, x), recipients}
  end

  # в алгоритме не работает
  def get_const([const_name | virt_code], data_stack, return_stack, dictionary, recipients) do
	case get_const(dictionary, const_name) do
	  :error -> {:error, "в словаре отсутствует объявленная константа #{const_name} "}
	  value	->  {virt_code, [value | data_stack], return_stack, dictionary, recipients}
	end   
  end


#-------------------
#  word of IO
#-------------------
  def emit(virt_code, [c | data_stack], return_stack, dictionary, recipients) do
    IO.write(<<c>>)
    {virt_code, data_stack, return_stack, dictionary, recipients}
  end

  def cr(virt_code, data_stack, return_stack, dictionary, recipients) do
    IO.write( "\n" )
    {virt_code, data_stack, return_stack, dictionary, recipients}
  end

  def dot(virt_code, data_stack, return_stack, dictionary, recipients) do
	data_stack = case data_stack do
	  [] -> IO.write("стек пуст ")  # !!! веревести в картеж 
			[]	
	  _  -> [x | tail] = data_stack
    		IO.write("#{x} ")
			tail
	end
    {virt_code, data_stack, return_stack, dictionary, recipients}
  end

  def dot_r(virt_code, [ width, value | data_stack], return_stack, dictionary, recipients) do
	string = case value do
	  value when is_integer(value) and  is_integer(width) ->  string = Integer.to_string(value)
														  	aligned_string(string, width)
	  value when is_float(value) and  is_integer(width) ->  string = Integer.to_string(value)
														  	aligned_string(string, width)
	  _ -> {:error, "ошибка параметров слова .R"}
	end
	IO.write(string)
    {virt_code, data_stack, return_stack, dictionary, recipients}
  end

  def dot_msg(virt_code, [message | data_stack], return_stack, dictionary, recipients) do
	 IO.write(message)
    {virt_code, data_stack, return_stack, dictionary, recipients}
  end

  def dump_data_stack(virt_code, data_stack, return_stack, dictionary, recipients) do
	#IO.puts("dump_data_stack")
	length = length(data_stack)
	IO.write("<#{length}> ")
    data_stack
    |> Enum.reverse()
    |> Enum.each(fn x -> IO.write("#{x} ") end)

    {virt_code, data_stack, return_stack, dictionary, recipients}
  end

  def space(virt_code, data_stack, return_stack, dictionary, recipients) do
    IO.write( " ")
    {virt_code, data_stack, return_stack, dictionary, recipients}
  end

  def spaces(virt_code, [amount |tail], return_stack, dictionary, recipients) do
    IO.write(String.duplicate(" ", amount))
    {virt_code, tail, return_stack, dictionary, recipients}
  end

  #-------------
  # flow control
  #-------------
  def do_word(virt_code, [count, end_count | data_stack], return_stack, dictionary, recipients) do
	#IO.puts(count)
	#IO.puts(end_count)

    { virt_code, data_stack, [count, end_count, %{do: virt_code} | return_stack],
      dictionary, recipients
	}
  end

  def i(virt_code, data_stack, [count, _end_count, %{do: _do_tokens} | _] = return_stack,
        dictionary, recipients) do
    {virt_code, [count | data_stack], return_stack, dictionary, recipients}
  end

  def j(virt_code, data_stack, [_count, _end_count, %{do: _do_tokens}, data | _] = return_stack,
        dictionary, recipients) do
    {virt_code, [data | data_stack], return_stack, dictionary, recipients}
  end


  def copy_r_to_d(virt_code, data_stack, [data | _] = return_stack, dictionary, recipients) do
    {
	  virt_code,
	  [data | data_stack],
	  return_stack,
	  dictionary, recipients
	}
  end

  def move_d_to_r(virt_code, [data | data_stack], return_stack, dictionary, recipients) do
    {
	  virt_code,
	  data_stack,
	  [data | return_stack],
	  dictionary, recipients
	}
  end

  def move_r_to_d(virt_code, data_stack, [data | return_stack], dictionary, recipients) do
    {
	  virt_code, 
	  [data | data_stack],
	  return_stack,
	  dictionary, recipients
	}
  end

  def loop(virt_code, data_stack, [count, end_count, %{do: do_tokens} | return_stack], dictionary, recipients) do
    count = count + 1

    case count < end_count do
      true	->	{ do_tokens, data_stack, [count, end_count, %{do: do_tokens} | return_stack],
          dictionary, recipients}
      false ->	{ virt_code, data_stack, return_stack, dictionary, recipients
		}
    end
  end

  def plus_loop(virt_code, [inc | data_stack], [count, end_count, %{do: do_tokens} | return_stack],
        dictionary, recipients) do
    count = count + inc
	sign = inc / abs(inc)
    case sign * count < sign * (end_count - 1) do
      true ->
        { do_tokens, data_stack, [count, end_count, %{do: do_tokens} | return_stack],
          dictionary, recipients}
      false ->
        { virt_code, data_stack, return_stack, dictionary, recipients}
    end
  end

  def begin(virt_code, data_stack, return_stack, dictionary, recipients) do
      IO.inspect(virt_code)
    { virt_code, data_stack, [%{begin: virt_code} | return_stack], dictionary, recipients  }
  end

  def until(virt_code,  [condition | data_stack], [%{begin: until_virt_code} | return_stack],
        dictionary, recipients) do
    # IO.puts(condition)
	# IO.inspect(virt_code)

    case is_falsely(condition) do
      true -> #IO.inspect(until_virt_code)
        {
          until_virt_code,
          data_stack,
          [%{begin: until_virt_code} | return_stack],
          dictionary, recipients
        }
      false -> #IO.inspect(virt_code)
        {
		  virt_code,
		  data_stack,
		  return_stack,
		  dictionary, recipients
		}
    end
  end

  def while(virt_code,  [condition | data_stack], [%{begin: while_virt_code} | return_stack],
        dictionary, recipients) do
    IO.puts(condition)
    #IO.inspect(virt_code)

    case is_falsely(condition) do
      false -> IO.inspect(while_virt_code)
        {
          virt_code,
          data_stack,
          [%{begin: while_virt_code} | return_stack],
          dictionary, recipients
        }
      true -> 
        {_virt_code, [:repeat | behind_virt_code]} = Enum.split_while(virt_code, fn s -> s != :repeat end)
        IO.inspect(while_virt_code)
        {
		  behind_virt_code,
		  data_stack,
		  return_stack,
		  dictionary, recipients
		}
    end
  end

  def repeat(virt_code,  data_stack, [%{begin: repeat_virt_code} | return_stack],
        dictionary, recipients) do
    IO.puts("repeat")
    IO.inspect(virt_code)

    {
      repeat_virt_code,
      data_stack,
      [%{begin: repeat_virt_code} | return_stack],
      dictionary, recipients
    }
  end


  def delay(virt_code, [delay | data_stack], return_stack, dictionary, recipients) do

    :timer.sleep(delay)

    { virt_code, data_stack, return_stack, dictionary, recipients}
  end

  # ---------------------------------------------
  # Stack operations
  # ---------------------------------------------
  def depth(virt_code, data_stack, return_stack, dictionary, recipients) do
    {virt_code, [length(data_stack) | data_stack], return_stack, dictionary, recipients}
  end

  def drop(virt_code, data_stack, return_stack, dictionary, recipients) do
	depth = length(data_stack)
	case depth do
	  0 -> 	{:error, "drop пустого стека\n"}
	  _ ->	[_ | cut_stack] = data_stack
			{virt_code, cut_stack, return_stack, dictionary, recipients}
	end
  end

  def drop2(virt_code, [_, _ | data_stack], return_stack, dictionary, recipients) do
    {virt_code, data_stack, return_stack, dictionary, recipients}
  end

  def dup(virt_code, [x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [x, x | data_stack], return_stack, dictionary, recipients}
  end

  def dup2(virt_code, [x, y | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [x, y, x, y | data_stack], return_stack, dictionary, recipients}
  end

  def dup?(virt_code, [x | _] = data_stack, return_stack, dictionary, recipients) when is_falsely(x) do
    {virt_code, data_stack, return_stack, dictionary, recipients}
  end

  def dup?(virt_code, [x | _] = data_stack, return_stack, dictionary, recipients) do
    {virt_code, [x | data_stack], return_stack, dictionary, recipients}
  end

  def swap(virt_code, [y, x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [x, y | data_stack], return_stack, dictionary, recipients}
  end

  def swap2(virt_code, [x1, y1, x2, y2 | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [x2, y2, x1, y1 | data_stack], return_stack, dictionary, recipients}
  end

  def over(virt_code, [x, y | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [y, x, y | data_stack], return_stack, dictionary, recipients}
  end

  def over2(virt_code, [x1, y1, x2, y2 | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [x2, y2, x1, y1, x2, y2 | data_stack], return_stack, dictionary, recipients}
  end

  def rot(virt_code, [z, y, x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [x, z, y | data_stack], return_stack, dictionary, recipients}
  end

  def rot_neg(virt_code, [z, y, x | data_stack], return_stack, dictionary, recipients) do
    {virt_code, [y, x, z | data_stack], return_stack, dictionary, recipients}
  end

  # ---------------------------------------------
  # Date & time operations
  # ---------------------------------------------
  def time_and_date(virt_code, data_stack, return_stack, dictionary, recipients) do
    naive_datetime = NaiveDateTime.local_now()
    year    = naive_datetime.year
    month   = naive_datetime.month
    day     = naive_datetime.day
    hour    = naive_datetime.hour
    minute  = naive_datetime.minute
    second  = naive_datetime.second
    #IO.puts(second)
    {virt_code, [ second, minute, hour, day, month, year | data_stack], return_stack, dictionary, recipients}
  end
   
  def timestamp(virt_code, data_stack, return_stack, dictionary, recipients) do
    naive_datetime = NaiveDateTime.local_now()
    {virt_code, [ naive_datetime | data_stack], return_stack, dictionary, recipients}
  end

  def ts_to_unix( virt_code, [timestamp | data_stack], return_stack, dictionary, recipients) do
    {:ok, dt} = DateTime.from_naive(timestamp,"Etc/UTC")
    {virt_code, [ DateTime.to_unix(dt, :millisecond) | data_stack], return_stack, dictionary, recipients}
  end

  def ts_from_unix( virt_code, [seconds | data_stack], return_stack, dictionary, recipients) do
    {:ok, timestamp} = DateTime.from_unix(seconds, :millisecond)
    {virt_code, [ timestamp | data_stack], return_stack, dictionary, recipients}
  end

  # ---------------------------------------------
  # server operations
  # ---------------------------------------------
  def forward(virt_code, data_stack, return_stack, dictionary, recipients) do
    #IO.inspect(recipients)
    mail = data_stack |> Enum.reverse |> List.to_tuple 
    Enum.each(recipients, fn pid ->
      send(pid, mail)
    end)
    {virt_code,  [], return_stack, dictionary, recipients}
  end

  # ---------------------------------------------
  # server operations
  # ---------------------------------------------
  def to_atom(virt_code, [string | data_stack], return_stack, dictionary, recipients) do
    atom = String.to_atom(string)
    {virt_code, [ atom | data_stack], return_stack, dictionary, recipients}
  end

end

