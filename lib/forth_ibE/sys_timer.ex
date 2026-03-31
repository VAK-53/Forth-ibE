defmodule SysTimer do
  @moduledoc """
  Documentation for `GlobalTimer`.
  """
  use GenServer
  @timer_name :sys_timer

  #--------------
  # API
  #--------------
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: @timer_name)
  end

  def get_sys_time do
    GenServer.call(@timer_name, :get_sys_time)
  end

  #----------------
  # implementation
  #----------------
  def init(_) do
    {:ok, :sys_timer} # получился сервер без состояния, только название
  end

  def handle_call(:get_sys_time, _from, state) do
    ts = DateTime.utc_now(:millisecond) |> DateTime.to_unix(:millisecond)
    { :reply, {:tick, ts, @timer_name}, state}
  end
end
