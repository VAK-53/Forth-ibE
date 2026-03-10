defmodule ForthIbE.REPL do

  use Task, restart: :transient

  import ForthIbE.Interpreter 	# interpret
  import ForthIbE.Tokenizer		# parse

  @doc """
  Starts the CLI and processes user commands.
  """
  def run() do
    loop(init(nil))
  end

  def init(dict) do     # далее проверка наличие словаря после перезапуска
    #IO.puts("в init repl")
    # заполняем таблицу встроенных слов
    file_names = [ "math_words.json", "io_words.json", "interpret_words.json", "flow_words.json", 
				 "logic_words.json", "stack_words.json", "time_words.json", "interprocess_words.json",
                 "conversion_words.json"]   # надо держать в конфиге
	:ok = ForthIbE.Table.init(file_names)
    
    file_names = ["in-built-words.txt"] # надо держать в конфиге
    dictionary = if dict == nil do 
      {:ok, dictionary} = ForthIbE.Dictionary.init(file_names)
      dictionary
    else
      dict
    end
  
    stocks  = [self()]
	forth_state = {[], [], [], dictionary} # virt_code = [] data_stack = [] return_stack = []
    %{forth: forth_state, stocks: stocks}
  end

  defp loop(full_state) do
    %{forth: {_virt_code, data_stack, return_stack, dictionary}, stocks: stocks} = full_state 
    input = IO.gets(" Words $ ") 
    tokens = parse(String.trim(input))

	#IO.inspect(tokens)
    # преобразуем токены в код
	{virt_code, dictionary} = case interpret(tokens, dictionary) do  # в dictionary помещаются определения! variable тоже
						  {:error, reason} -> IO.puts(reason)
                                              full_state = %{forth: {[],[], [], dictionary}, stocks: stocks} 
											  loop(full_state)
						  {virt_code, dictionary} -> case virt_code do  # похоже, это проверка пустой кода
										  []		->	forth_state = {virt_code, data_stack, return_stack, dictionary}
                                                        full_state = %{forth: forth_state, stocks: stocks} 
                                                        loop(full_state)
										  _			->	{virt_code, dictionary}	# что за случай? основной? 
						  end			  
	end	
    #IO.inspect(virt_code)
	# выполнение вирт-кода
    try do 
        forth_state = {virt_code, data_stack, return_stack, dictionary}
        full_state  = %{forth: forth_state, stocks: stocks}
	    {virt_code, data_stack, return_stack, dictionary} = case ForthIbE.Executer.evaluate(full_state) do 
	      {:ok, [], data_stack, return_stack, dictionary}   ->  IO.write(" ok\n")
														    {[], data_stack, return_stack, dictionary}
	      {:error, reason}                              ->	IO.puts(reason) # а надо бы возвращать virt_code
							                                {[], [], [], dictionary}  
	    end
        full_state = %{forth: {virt_code, data_stack, return_stack, dictionary}, stocks: stocks}  
        loop(full_state)
    catch _error_type, error_value ->
                #IO.puts("Type: #{inspect(error_type)}")
                #IO.puts("Value: #{inspect(error_value)}")
                case error_value do
                  :normal -> IO.puts("Выходим")
                             System.halt(0)

                  _ ->      IO.puts("Ошибка:")
                            IO.puts("\tКод: #{inspect(virt_code)}")
                            loop(init(dictionary))
                end
        end
  end
end
