defmodule DockerStream.Broadcaster do
  alias DockerStream.RegistrationAgent

  @broadcaster DockerStream.Broadcaster

  def start_link do
    {:ok, pid} = GenEvent.start_link(name: @broadcaster)

    RegistrationAgent.registrations
      |> Enum.each(fn({module, args}) -> register(module, args) end)

    {:ok, pid}
  end

  def register(module, args) do
    RegistrationAgent.register(module, args)
    GenEvent.add_handler(@broadcaster, module, args)
  end

  def deregister(module, term) do
    RegistrationAgent.deregister(module)
    GenEvent.remove_handler(@broadcaster, module, term)
  end

  def notify(event) do
    GenEvent.ack_notify(@broadcaster, event)
  end

end
