defmodule ForthIbE.Table do
  @moduledoc """
  Модуль работы с таблицей встроенных функций.
  """
  def init() do
	{:ok, %{}}
  end

  def get_atom(word) do          # !!!!
    #IO.puts("get in sys_table " <> word)
    #IO.inspect(:ets.lookup(:sys_table, word))
    case :ets.lookup(:sys_table, word) do
      [{_word, atom, _type}]  ->  atom
      [] ->	{:unknown, word}
    end
  end

  def get_at_om(table, atom) do          # !!!!
    #IO.puts("get in table " <> atom)
    case Map.has_key?(table, atom) do
      true  -> Map.get(table, atom) 
      false ->	{:unknown, atom}
    end
  end
end
