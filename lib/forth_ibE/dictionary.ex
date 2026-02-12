defmodule ForthIbE.Dictionary do
  @moduledoc """
  Модуль работы со словарём слов и переменных.
  """
  def init() do
	{:ok, %{}}
  end

  def get_value(dict, word_name) do
    case Map.has_key?(dict, word_name) do
      true -> Map.get(dict, word_name) 
      false ->	{ :unknown, word_name }
    end
  end

  def get_word(dict, word) do
    IO.puts("Этого не должно быть " <> word)
  end

  def exist?(dict, word_name) do
    Map.has_key?(dict, word_name) 
  end

  def add(dict, word_name, word, doc \\ %{stack: "( )", doc: ""})
      when is_list(word) or is_function(word) do
    Map.put(dict, word_name, {:word, word, doc})
  end

  def add_word(dict, word_name, words \\ []) do
    #IO.puts("добавляем в словарь определение слова")
    Map.put(dict, word_name, {:words, words})
  end

  def add_var(dict, word_name, value ) do
	#IO.puts("В Словаре")
    Map.put(dict, word_name, {:var, value})
  end

  def set_var(dict, word_name, value) do
	case exist?(dict, word_name) do
	  true 	-> Map.put(dict, word_name, {:var, value})
	  false -> :error
	end
  end

  def get_var(dict, word_name) do
	case exist?(dict, word_name) do
      true	-> 	{:var, value} = Map.get(dict, word_name ) 
    			value
	  false -> :error
	end
  end

  @spec add_const(map, any, any) :: map
  def add_const(dict, word_name, value) do
    Map.put(dict, word_name, {:const, value})
  end

  def get_const(dict, const_name) do # в алгоритме не работает
	case exist?(dict, const_name) do
      true	-> 	case Map.get(dict, const_name ) do
    			  {:const, value} -> value
				  _		-> :error
				end
	  false -> :error
	end
  end

end
