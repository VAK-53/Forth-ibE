defmodule ForthIbE.Compouser do
  @moduledoc """
  Загрузка таблицы настройки интерпретатора
  """

  @root_dir File.cwd!

  def storage_dir(), do: @root_dir <> "/lib/priv"
  def words_dir(), do: @root_dir <> "/lib"

  def compouse(table) do #
	# IO.puts(@root_dir)
 	file_names = [ "math_words.json", "io_words.json", "interpret_words.json", "flow_words.json", 
				 "logic_words.json",	"stack_words.json", "time_words.json", "server_words.json",
                 "elixir_words.json"] # 
    bootstrap_table = for file_name <- file_names do
	  full_name = Path.join(storage_dir(), file_name)

	  case File.read(full_name) do
		{:ok, content} -> 
		  case JSON.decode(content) do # читаем таблицу слов
			{:ok, acc} ->  acc
		 	{:unexpected_end, _offset} ->
				IO.puts("binary содержит неполное значение JSON")
			{:error, {:invalid_byte, offset, byte}} -> 
				IO.puts("binary содержит неожиданный байт или недопустимый байт #{byte} в #{offset}")
			{:unexpected_sequence, _offset, bytes} ->
				IO.puts("binary содержит недопустимый экранированный символ UTF-8 #{bytes}")
		  end
		{:error, reason} -> IO.puts("Failed to read file: #{reason}")
	  end
	end

	# объединяем таблицы начальных word
	lex_table = Enum.reduce(bootstrap_table, %{}, 
	  					fn table, lex_table -> Map.merge(lex_table, table) end
				)

	# преобразуем бинарные строки в атомы; необходимость отпала: полностью перешли на словарь
	#lex_table = keys_to_atom(lex_table)

	# Проверяем наличие функций атомов
	fun_check(lex_table)	
 
	# заполняем словарь стандартными words
	new_table = fill_table(lex_table, table)
    # IO.inspect(new_table)
	{:ok, new_table}
 end

  defp fun_check(lex_table) do
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


  defp fill_table(lex_table, table) do
	new_table = Enum.reduce(lex_table, %{},
		fn elem, table -> attrs = elem(elem,1)
							   key = elem(elem,0)
							   name = Map.get(attrs, "name")
							   Map.put(table,  key, String.to_atom(name))
		end )
	Map.merge(table, new_table)
  end
end
