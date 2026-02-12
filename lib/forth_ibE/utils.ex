defmodule ForthIbE.Utils do
  @moduledoc false

  #-----------
  # утилиты
  #-----------

  defguard is_falsely(value) when value == false or value == nil or value == 0 or value == ""
  defguard is_truthly(value) when not is_falsely(value)

  def atomization(tokens_list) do
	Enum.reverse(_atomization(tokens_list))
  end

  defp _atomization([]) do
	[]
  end

  defp _atomization([token | tail]) do
	new_token = case token do
	  token when is_binary(token) -> String.to_atom(token)
	  _ -> token
  	end
	[new_token | _atomization(tail) ]
  end

  def aligned_string(string, width) do	# выравнивание строки пробелами по ширине
	length = String.length(string)
	field_length = width - length
	field =  case field_length > 0 do
	  false -> ""
	  true 	-> String.duplicate(" ", field_length) 
	end
	field <> string
  end
end

