defmodule NginxRegistry.Api do
  def container_available(event) do
    IO.puts "adding container #{event.name}"
    NginxRegistry.Registry.register(event)
  end
  def container_unavailable(event) do
    IO.puts "removing container #{event.name}"
    NginxRegistry.Registry.unregister(event)
  end
end
