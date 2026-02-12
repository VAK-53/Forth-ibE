defmodule ForthIbE.Table do
  @moduledoc """
  Модуль работы с таблицей встроенных функций.
  """
  def init() do
	{:ok, %{}}
  end

  def get(table, word_name, stack) do # вообще не нужно
    case Map.has_key?(table, word_name) do
      true -> case Map.get(table, word_name) do
				{name, :name} -> apply(ForthIbE.Words, name, [stack])
				{:byte_code, code} -> code # это код или значение переменной!
			  end
      false -> { :unknown, word_name }
    end
  end

  def get_atom(table, atom) do
    #IO.puts("get in table " <> atom)
    case Map.has_key?(table, atom) do
      true  -> Map.get(table, atom) 
      false ->	{:unknown, atom}
    end
  end

  def exist?(table, word_name) do
    Map.has_key?(table, word_name) 
  end

  def add(table, word_name, word, doc \\ %{stack: "( )", doc: ""})
      when is_list(word) or is_function(word) do
    Map.put(table, word_name, {:word, word, doc})
  end

end
