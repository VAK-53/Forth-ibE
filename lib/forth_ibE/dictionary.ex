defmodule ForthIbE.Dictionary do
  @moduledoc """
  Модуль работы со словарем слов.
  """
  def init() do
	{:ok, %{}}
  end

  def get(dictionary, word_name, stack) do
    case Map.has_key?(dictionary, word_name) do
      true -> case Map.get(dictionary, word_name) do
				{name, :name} -> apply(ForthIbE.Words, name, [stack])
				{:byte_code, code} -> code # это код или значение переменной!
			  end
      false -> { :unknown, word_name }
    end
  end

  def get(dictionary, word_name) do
    case Map.has_key?(dictionary, word_name) do
      true -> Map.get(dictionary, word_name) 
      false ->	{ :unknown, word_name }
    end
  end

  def exist?(dictionary, word_name) do
    Map.has_key?(dictionary, word_name) 
  end

  def add(dictionary, word_name, word, doc \\ %{stack: "( )", doc: ""})
      when is_list(word) or is_function(word) do
    Map.put(dictionary, word_name, {:word, word, doc})
  end

  def add_word(dictionary, word_name, words \\ []) do
    Map.put(dictionary, word_name, {:words, words})
  end

  def add_var(dictionary, word_name, value \\ nil) do
	#IO.puts("В Словаре")
    Map.put(dictionary, word_name, {:var, value})
  end

  def set_var(dictionary, word_name, value) do
	case exist?(dictionary, word_name) do
	  true 	-> Map.put(dictionary, word_name, {:var, value})
	  false -> :error
	end
  end

  def get_var(dictionary, word_name) do
	case exist?(dictionary, word_name) do
      true	-> 	{:var, value} = Map.get(dictionary, word_name ) # ? {:var, :unknown}
    			value
	  false -> :error
	end
  end

  @spec add_const(map, any, any) :: map
  def add_const(dictionary, word_name, value) do
    Map.put(dictionary, word_name, {:const, value})
  end

  def get_const(dictionary, const_name) do # в алгоритме не работает
	case exist?(dictionary, const_name) do
      true	-> 	case Map.get(dictionary, const_name ) do
    			  {:const, value} -> value
				  _		-> :error
				end
	  false -> :error
	end
  end

end
