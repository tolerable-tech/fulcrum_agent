defmodule DockerStream.DockerApi do
  use HTTPoison.Base

  def docker_endpoint(path \\ "") do
    #beg = (Application.get_env(:fulcrum_agent, :docker_url) || System.get_env("DOCKER_HOST"))
    #if(String.starts_with?(beg, "tcp://")) do
      #beg = String.replace(beg, "tcp", "http")
    #end
    Fulcrum.Settings.docker_url <> path
  end

  def process_url(url) do
    docker_endpoint(url)
  end

  def stream_events(to) do
    IO.puts "issuing new request"
    request_id = get("/events", [{"Accept", "application/json"}], stream_to: to,
      recv_timeout: :infinity)
    #send(to, {:request_id, request_id})
    to
  end

  def inspect_container(container_id) do
    get!("/containers/#{container_id}/json").body
  end

  def process_response_body(body) do
    case body |> Poison.decode do
      {:ok, pbody} ->
        pbody
      _ ->
        %{"Name" => "unknown", "NetworkSettings" => %{"IPAddress" => "unknown",
            "Ports" => %{}}}
    end
  end
end
