defmodule DockerStream.EventStreamer do
  alias DockerStream.DockerApi
  alias DockerStream.EventProcessor
  use GenServer
  import Supervisor.Spec, only: [worker: 2]
  @name __MODULE__
  @self __MODULE__

  def add_to_supervisor do
    Supervisor.start_child(DockerStream.Supervisor, worker(@name, []))
  end

  def start_link() do
    GenServer.start_link(@name, [], name: @name)
  end

  def init(docker_endpoint) do
    tid = request_events

    {:ok, %{tid: tid, fulcrum_name: Application.get_env(:fulcrum_agent, :fulcrum_app), rid: nil}}
  end

  #
  # Public GenServer API
  #

  def received_chunks do
    GenServer.call(@self, {:received_chunks})
  end

  def stream_died do
    GenServer.cast(@self, {:stream_died})
  end

  def receive_chunk(chunk) do
    GenServer.cast @self, {:receive_chunk, chunk}
  end

  def streamer_request_id(id) do
    GenServer.cast(@self, {:streamer_request_id, id})
  end

  def request_events do
    spawn_link(@name, :listen, []) |> DockerApi.stream_events
  end

  def listen do
    receive do
      {:request_id, id} ->
        IO.puts "got request id!"
        streamer_request_id(id)
      status = %HTTPoison.AsyncStatus{} ->
        listen
      headers = %HTTPoison.AsyncHeaders{} ->
        listen
      async_end = %HTTPoison.AsyncEnd{} ->
        IO.puts("fuck endings")
        IO.inspect(async_end)
        stream_died
      err = %HTTPoison.Error{reason: {:closed, :timeout}} ->
        stream_died
      err = %HTTPoison.Error{} ->
        IO.puts("fuck errors")
        IO.inspect(err)
        stream_died
      chunk = %HTTPoison.AsyncChunk{} ->
        receive_chunk(chunk)
        listen
    end
  end

  def handle_cast({:receive_chunk, chunk}, state) do
    EventProcessor.call(chunk.chunk)

    {:noreply, state}
  end

  def handle_cast({:stream_died}, state) do
    {:noreply, %{state | tid: request_events}}
  end

  def handle_cast({:streamer_request_id, id}, state) do
    {:noreply, %{state | rid: id}}
  end

  def handle_info({:DOWN, ref, :process, pid, :normal}, state) do
    # the EventProcessor task process exited normally
    {:noreply, state}
  end
  def handle_info({ref, return}, state) when is_reference(ref) do
    # we receive the return code of the EventProcessor Task here.
    {:noreply, state}
  end

  def handle_info(info, state) do
    IO.puts "======="
    IO.inspect info
    IO.puts "======="
    {:noreply, state}
  end
end
