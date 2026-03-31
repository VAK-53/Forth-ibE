defmodule ForthIbE.Table do
  @moduledoc """
  Модуль работы с таблицей встроенных функций.
  """

  @global_table :sys_table

  def init do
    #IO.puts("в init table")
    if false == :lists.member(@global_table, :ets.all()) do
      #IO.puts("в if")
      :ets.new(@global_table, [:public, :named_table])
      :ok = ForthIbE.Compouser.compouse 
    end
    :ok
  end

  def get_atom_from_table(word) do          # !!!!
    case :ets.lookup(:sys_table, word) do
      [{_word, atom, _type}]  ->  atom
      [] ->	:unknown
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
