defmodule ForthIbE.REPL do

  use Task, restart: :transient

  import ForthIbE.Interpreter 	# interpret
  import ForthIbE.Engin			# evaluate
  import ForthIbE.Compouser		# compouse
  import ForthIbE.Tokenizer		# parse

  @doc """
  Starts the CLI and processes user commands.
  """
  def run() do
    loop(init(nil))
  end

  def init(dict) do
    dictionary = if dict == nil do 
      {:ok, dictionary} = ForthIbE.Dictionary.init()
      dictionary
    else
      dict
    end
	#{:ok, table} = ForthIbE.Table.init() #, table
    file_names = [ "math_words.json", "io_words.json", "interpret_words.json", "flow_words.json", 
				 "logic_words.json", "stack_words.json", "time_words.json", "interprocess_words.json",
                 "conversion_words.json"]
    :ets.new(:sys_table, [:public, :named_table])
    :ok = compouse(file_names) #, table table file_names надо выше определять
	data_stack = []
	return_stack = []
    recipients  = [self()]
	{data_stack, return_stack, dictionary, recipients} #, table
  end

  defp loop(state) do
    {data_stack, return_stack, dictionary, recipients} = state #, table
    input = IO.gets(" Words $ ") 
	#IO.inspect(input)
    tokens = parse(String.trim(input))

	#IO.inspect(tokens)
	{virt_code, dictionary} = case interpret(tokens, dictionary) do  # в dictionary помещаются определения! variable тоже? #, table
						  {:error, reason} -> IO.puts(reason)
                                              state = {[], [], dictionary, recipients}  #, table
											  loop(state)
						  {virt_code, dictionary} -> 
										case virt_code do
										  []		->	state = {data_stack, return_stack, dictionary, recipients}  #, table
                                                        loop(state)
										  _			->	{virt_code, dictionary}	
										end			  
		end	
		# выполнение вирт-кода
        try do 
            #IO.inspect(virt_code)
            #IO.inspect(dictionary)
            #IO.gets(" Пауза $ ")
		    {data_stack, return_stack, dictionary} = case evaluate(virt_code, data_stack, return_stack, dictionary, recipients) do #, table
		      {:ok, data_stack, return_stack, dictionary}   ->  IO.write(" ok\n")
															    { data_stack, return_stack, dictionary}
		      {:error, reason}                              ->	IO.puts(reason)
								                                {[], [], dictionary}
		    end
            state = {data_stack, return_stack, dictionary, recipients}  #, table
            loop(state)
        catch error_type, error_value ->
                IO.puts("Type: #{inspect(error_type)}")
                IO.puts("Value: #{inspect(error_value)}")
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
