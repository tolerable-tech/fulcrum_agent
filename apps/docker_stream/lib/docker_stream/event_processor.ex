defmodule DockerStream.EventProcessor do
  alias DockerStream.Broadcaster
  alias DockerStream.DockerApi

  @interesting_stati ~w(create start die destroy)

  def call(event) do
    Task.async(__MODULE__, :process, [event])
  end

  # container events
  # attach, commit, copy, create, destroy, die, exec_create, exec_start, export,
  # kill, oom, pause, rename, resize, restart, start, stop, top, unpause

  # image events
  # delete, import, pull, push, tag, untag

  def process(event) when is_binary(event) do
    event |> Poison.decode! |> process
  end
  def process(event = %{"status" => status}) when status in @interesting_stati do
    %DockerStream.Event{type: status, id: event["id"], time: event["time"]}
    |> apply_container_info
    |> Broadcaster.notify
    :ok
  end
  #def process(event = %{"status" => "start"}) do
    #IO.puts "PROCESSING START EVENT BRO #{event.id}"
  #end
  #def process(event = %{"status" => "die"}) do
    #IO.puts "DIE: PROCESSING die EVENT BRO"
  #end
  #def process(event = %{"status" => "destroy"}) do
    #IO.puts "DESTROY: PROCESSING destroy EVENT BRO"
  #end
  def process(event) do
    :ok
  end

  defp apply_container_info(event) do
    cinfo = DockerApi.inspect_container(event.id)
    %{event | name: cinfo["Name"] |> strip_leading_slash,
                ip: cinfo["NetworkSettings"]["IPAddress"],
             ports: cinfo["NetworkSettings"]["Ports"]
     }
  end

  defp strip_leading_slash(name) when is_binary(name) do
    {_, rest} = String.split_at(name, 1)
    rest
  end
  defp strip_leading_slash(name), do: name
end
