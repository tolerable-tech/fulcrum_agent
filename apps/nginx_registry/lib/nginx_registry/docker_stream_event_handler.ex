defmodule NginxRegistry.DockerStreamEventHandler do
  use GenEvent

  def register() do
    #IO.puts "made it here!"
    DockerStream.Api.register(__MODULE__, %{})
    #DockerStream.Broadcaster.register(__MODULE__, self)
    {:ok, self}
  end

  def handle_event(event = %DockerStream.Event{type: "start"}, parent) do
    NginxRegistry.Api.container_available(event)

    {:ok, parent}
  end
  def handle_event(event = %DockerStream.Event{type: "die"}, parent) do
    NginxRegistry.Api.container_unavailable(event)
    {:ok, parent}
  end
  def handle_event(event, parent) do
    #NginxRegistry.Api.container_unavailable(event)
    {:ok, parent}
  end
end
