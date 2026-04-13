defmodule ForthIbE.REPL do

  use Task, restart: :transient

  import ForthIbE.Interpreter 	# interpret
  import ForthIbE.Tokenizer		# parse
  import ForthIbE.Executer 	    # evaluate

  @doc """
  Starts the CLI and processes user commands.
  """
  def run() do
    state = init(nil)
    loop(state)
  end

  def init(dict) do     # далее проверка наличие словаря после перезапуска
    # заполняем таблицу встроенных слов
	:ok = ForthIbE.Table.init
    #IO.inspect(:ets.tab2list(:sys_table))    

    dictionary = if dict == nil do 
      {:ok, dictionary} = ForthIbE.Dictionary.init
      dictionary
    else
      dict
    end

	{[], [], [], dictionary} # state
  end

  defp loop(state) do
    {_virt_code, _data_stack, _return_stack, dictionary} = state 
    try do
      #IO.puts("В REPL")
	  new_state = IO.gets("~Words $ ") |> String.trim |> 
                  parse |> interpret(state) |>  evaluate  
	   
      IO.write(" ok\n")
      loop(new_state)
    rescue 
      e in ExecuterError ->
                case e.message do
                  "exit" -> IO.puts("Выходим")
                            System.halt(0)

                  "division by zero" -> IO.puts("Деление на 0.")
                  "negative root value" ->
                                        IO.puts("Отрицательное подкоренное выражение.")
                  "there's no declared variable" ->
                                        IO.puts("Отсутствует требуемая переменная #{e.name}.")
                  "there's no need constant" ->
                                        IO.puts("Отсутствует требуемая константа \"#{e.name}\".")
                  "undefined variable"  ->
                                        IO.puts("Значение переменной \"#{e.name}\" не определено.")         
                  "not number"  ->
                                        IO.puts("Значение \"#{e.name}\" не является числом.")             
                  "an empty stack"  ->
                                        IO.puts("Cтек пуст.")
                end
                  IO.puts("Стек: #{inspect(e.stack)}")
                  IO.puts("Код: #{inspect(e.code)}")
                  loop(init(e.dict))

      e in InterpretError -> 
                case e.message do
                  "incorrect if-else-then structure" ->
                                        IO.puts("Направильная структура if-else-then")
                                        IO.puts("Код: #{inspect(e.code)}")
                                        loop(init(dictionary))
                end
      e in ComposeError -> 
                case e.message do
                  "incomplete value JSON"   ->      IO.puts("При разборе файла #{e.file} binary содержит неполное значение JSON")

                  "unexpected or invalid byte" ->   IO.puts("При разборе файла #{e.file} binary содержит неожиданный или недопустимый байт")

                  "invalid escaped character" ->    IO.puts("При разборе файла #{e.file} binary содержит недопустимый экранированный символ UTF-8")

                  "Failed to read file"       ->    IO.puts("Не удалось прочитать файл #{e.file}")
                end
                exit(:normal)
    end
  end
end
