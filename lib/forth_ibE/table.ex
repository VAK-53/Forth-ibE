defmodule ForthIbE.Table do
  @moduledoc """
  Модуль работы с таблицей встроенных функций.
  """
  #import ForthIbE.Compouser		# compouse

  @global_table :sys_table

  def init(file_names) do
    #IO.puts("в init table")
    if false == :lists.member(@global_table, :ets.all()) do
      #IO.puts("в if")
      :ets.new(@global_table, [:public, :named_table])
      :ok = ForthIbE.Compouser.compouse(file_names) 
    end
    :ok
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
