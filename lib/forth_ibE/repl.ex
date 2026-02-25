defmodule ForthIbE.REPL do

  use Task, restart: :transient

  import ForthIbE.Interpreter 	# interpret
  #import ForthIbE.Engin		# evaluate
  import ForthIbE.Tokenizer		# parse

  @doc """
  Starts the CLI and processes user commands.
  """
  def run() do
    loop(init(nil))
  end

  def init(dict) do     # далее проверка наличие словаря после перезапуска
    #IO.puts("в init repl")
    dictionary = if dict == nil do 
      {:ok, dictionary} = ForthIbE.Dictionary.init()
      dictionary
    else
      dict
    end
    file_names = [ "math_words.json", "io_words.json", "interpret_words.json", "flow_words.json", 
				 "logic_words.json", "stack_words.json", "time_words.json", "interprocess_words.json",
                 "conversion_words.json"]
	:ok = ForthIbE.Table.init(file_names)
	data_stack = []
	return_stack = []
    stocks  = [self()]
	forth_state = {data_stack, return_stack, dictionary}
    {forth_state, stocks}
  end

  defp loop(full_state) do
    {{data_stack, return_stack, dictionary}, stocks} = full_state 
    input = IO.gets(" Words $ ") 
    tokens = parse(String.trim(input))

	#IO.inspect(tokens)
    # преобразуем токены в код
	{virt_code, dictionary} = case interpret(tokens, dictionary) do  # в dictionary помещаются определения! variable тоже
						  {:error, reason} -> IO.puts(reason)
                                              full_state = {{[], [], dictionary}, stocks} 
											  loop(full_state)
						  {virt_code, dictionary} -> case virt_code do  # похоже это проверка пустой кода
										  []		->	forth_state = {data_stack, return_stack, dictionary}
                                                        full_state = {forth_state, stocks} 
                                                        loop(full_state)
										  _			->	{virt_code, dictionary}	# что за случай? основной? 
						  end			  
	end	
    #IO.inspect(virt_code)
	# выполнение вирт-кода
    try do 
        forth_state = {virt_code, data_stack, return_stack, dictionary}
        full_state  = {forth_state, stocks}
	    {data_stack, return_stack, dictionary} = case ForthIbE.Engin.evaluate(full_state) do 
	      {:ok, data_stack, return_stack, dictionary}   ->  IO.write(" ok\n")
														    { data_stack, return_stack, dictionary}
	      {:error, reason}                              ->	IO.puts(reason)
							                                {[], [], dictionary}
	    end
        full_state = {{data_stack, return_stack, dictionary}, stocks}  
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
