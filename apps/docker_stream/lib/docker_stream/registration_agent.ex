defmodule DockerStream.RegistrationAgent do
  @name DockerStream.RegistrationAgent

  def start_link do
    Agent.start_link(fn -> HashDict.new end, name: @name)
  end

  def registrations do
    Agent.get(@name, fn(list) -> list end)
  end

  def register(module, args) do
    Agent.update(@name, fn(dict) ->
      Dict.put(dict, module, args)
    end)
  end

  def deregister(module) do
    Agent.update(@name, fn(dict) ->
      Dict.delete(dict, module)
    end)
  end
end
