alias DockerStream.Broadcaster
alias DockerStream.DockerApi
alias DockerStream.Api

defmodule Forwarder do
  use GenEvent

  def handle_event(event, parent) do
    IO.puts "===   Received an Event:"
    IO.inspect(event)
    IO.puts "==="
    {:ok, parent}
  end
end


