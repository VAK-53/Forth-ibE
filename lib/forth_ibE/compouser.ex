defmodule ForthIbE.Compouser do
  @moduledoc """
  Загрузка таблицы настройки интерпретатора
  """
  
  import  ForthIbE.Utils
  # @root_dir File.cwd!

  # def storage_dir(), do: @root_dir <> "/lib/priv"

  def compouse do #
	# IO.puts(@root_dir)
	#{:ok, table} = ForthIbE.Table.init()
    
    list_name = Path.join(storage_dir(), "list.txt")
    {:ok, lines} = File.read(list_name)
    file_names = lines |> String.split("\n", trim: true)
    bootstrap_table = for file_name <- file_names do
	  full_name = Path.join(storage_dir(), file_name)

	  case File.read(full_name) do
		{:ok, content} -> 
		  case JSON.decode(content) do # читаем таблицу слов
			{:ok, acc} ->  acc
		 	{:unexpected_end, _offset} ->
                raise ComposeError, message: "incomplete value JSON", file: file_name
			{:error, {:invalid_byte, _offset, _byte}} -> 
                raise ComposeError, message: "unexpected or invalid byte", file: file_name
			{:unexpected_sequence, _offset, _bytes} ->
                raise ComposeError, message: "invalid escaped character", file: file_name
		  end
		{:error, _reason} -> raise ComposeError, message: "Failed to read file", file: file_name
	  end
	end

	# объединяем таблицы начальных word
	lex_table = Enum.reduce(bootstrap_table, %{}, 
	  					fn table, lex_table -> Map.merge(lex_table, table) end
				)

	# Проверяем наличие функций атомов
	fun_check(lex_table)	
 
	# заполняем словарь стандартными words
	fill_table(lex_table)   
    #IO.inspect(new_table)
	:ok   
 end

  defp fun_check(lex_table) do # проверка функций
	Enum.each( # удалить
	  lex_table,
	  fn elem -> key   = elem(elem,0)
				 attrs = elem(elem,1)
				 name  = Map.get(attrs, "name")
				 check = Keyword.has_key?(ForthIbE.Words.__info__(:functions), String.to_atom(name))
				 if !check, do: IO.puts("Нет функции #{name} у атома #{key}")
	  end
	)
  end


  defp fill_table(lex_table) do 
	Enum.reduce(lex_table, %{},
		fn elem, table ->   attrs = elem(elem,1)
						    key =  elem(elem,0) #String.downcase()
						    name = Map.get(attrs, "name") |> String.to_atom
                            type = Map.get(attrs, "type")
                            :ets.insert(:sys_table, {key, name, type})
						    Map.put(table,  key, name)
		end )
    #IO.inspect(new_table)
	#Map.merge(table, new_table)
  end
end
