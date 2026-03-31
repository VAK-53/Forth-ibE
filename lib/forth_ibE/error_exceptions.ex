defmodule InterpretError do
  defexception message: "Something", code: nil, token: nil, dict: nil
end

defmodule ExecuterError do
  defexception message: "Something", code: nil, stack: nil, dict: nil, name: nil
end

defmodule ComposeError do
  defexception message: "Something", file: nil
end
