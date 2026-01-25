defmodule Mix.Tasks.Repl do
  use Mix.Task

  def run(_) do
    {:ok, version} = :application.get_key(:forth_ibe, :vsn)
    IO.puts("Forth-ibE REPL #(v#{version})") 

    ForthIbE.REPL.run()
  end
end
