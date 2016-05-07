defmodule DockerStream.Api do
  alias DockerStream.Broadcaster

  def register(module, args), do: Broadcaster.register(module, args)
  def deregister(module, args), do: Broadcaster.deregister(module, args)

end
