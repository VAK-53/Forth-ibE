defmodule ForthIbE.REPL do

  use Task, restart: :transient

  import ForthIbE.Interpreter 	# interpret
  import ForthIbE.Engin			# run
  import ForthIbE.Compouser		# compouse
  import ForthIbE.Tokenizer		# parse

  @doc """
  Starts the CLI and processes user commands.
  """
  def run() do
    loop(init(nil))
  end

  def init(_) do
	{:ok, dictionary} = ForthIbE.Dictionary.init()
    {:ok, _lex_table, dictionary} = compouse(dictionary) # непонятно, зачем _lex_table?
	stack = []
	return_stack = []
	{ stack, return_stack, dictionary}
  end

  defp loop({data_stack, return_stack, dictionary}) do
    in_string = IO.gets(" Words $ ") 
    tokens = parse(String.trim(in_string))

	#IO.inspect(tokens)
	derivation = interpret(tokens, dictionary)
	{virt_code, dictionary} = case derivation do 
						  {:error, reason} -> IO.puts(reason)
											  loop {[], [], dictionary}
						  {virt_code, dictionary} -> 
										case virt_code do
										  []		->	loop({data_stack, return_stack, dictionary})
										  #[:exit]	->	:exit
										  _			->	{virt_code, dictionary}	
										end			  
		end	
		# выполнение вирт-кода
      try do 
            # IO.inspect(virt_code)
		    result = case run(virt_code, data_stack, return_stack, dictionary) do
		      {:ok, data_stack, return_stack, dictionary} ->	IO.write(" ok\n")
															    {data_stack, return_stack, dictionary}
		      {:error, reason} ->	IO.puts(reason)
								    {[], [], dictionary}
		    end
            loop(result)
      catch _error_type, error_value ->
        #IO.puts("Type: #{inspect(error_type)}")
        #IO.puts("Value: #{inspect(error_value)}")
        case error_value do
          :normal -> IO.puts("Выходим")
                     System.halt(0)
          _ ->
            IO.puts("Ошибка:")
            IO.puts("\tКод: #{inspect(virt_code)}")
            IO.puts("\tСтек: #{inspect(data_stack)}")
            IO.puts("\tСтек возврата: #{inspect(return_stack)}")
            loop(init(nil))
        end
      end
  end

  def child_spec(opts) do
    %{
        id: __MODULE__,
        start: {__MODULE__, :start_link, [opts]},
        type: :worker,
        restart: :transient,
        shutdown: 500
    }
  end
end
