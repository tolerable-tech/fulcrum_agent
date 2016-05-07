defmodule NginxRegistry.Registry do
  use GenServer
  alias Fulcrum.DataStore.Container

  @name __MODULE__

  def start_link do
    GenServer.start_link(@name, [], name: @name)
  end

  def init([]) do
    {:ok, conn} = GenServer.start_link(Etcd.Connection,
      %Etcd.Connection{hosts: [Fulcrum.Settings.etcd_host]})

    {:ok, %{conn: conn, private_ip: Fulcrum.Settings.coreos_private_ipv4}}
  end

  def register(event) do
    GenServer.call(@name, {:register, event})
  end

  def unregister(event) do
    GenServer.call(@name, {:unregister, event})
  end

  def handle_call({:register, event}, _from, state) do
    instance = Container.instance_for(event.name, preload: [:component])

    IO.puts "Adding container #{inspect event}"

    if(instance != :unknown && "http" in instance.component.provides,
      do: do_register(event, instance, state.conn))

    {:reply, {:ok}, state}
  end

  def handle_call({:unregister, event}, _from, state) do
    instance = Container.instance_for(event.name, preload: [:component])

    if(instance != :unknown && "http" in instance.component.provides,
       do: do_unregister(event, instance, state.conn))

    {:reply, {:ok}, state}
  end

  defp do_register(%{ports:  ports}, _, _) when ports in [%{}], do: :ok
  defp do_register(event, instance, conn) do
    IO.puts " -- registering #{instance.component.name}"
    event
    |> keys_and_values_for(instance)
    |> set_list_in_etcd(conn)
  end

  defp do_unregister(event, instance, conn) do
    event
    |> keys_for(instance)
    |> remove_list_in_etcd(conn)
  end

  defp keys_and_values_for(event, instance) do
    component_name = instance.component.name

    vhosts = Enum.map(Container.hostnames_for(instance), fn(name) ->
      {"/apps/#{component_name}/vhost/", :assign, name}
    end)

    case Container.endpoint_for(instance) do
      nil -> :ok
      endpoint -> 
        IO.puts " -- - setting endpoint for #{inspect event} => #{endpoint}"
        vhosts = [{"/apps/#{component_name}/endpoint", endpoint} | vhosts]
    end

    out = [{"/apps/#{component_name}", :dir}, {"/apps/#{component_name}/vhost", :dir},
     {"/apps/#{component_name}", :assign, bound_port_for(event, instance)} | vhosts]
    IO.inspect out
    out
  end

  defp keys_for(event, instance) do
    component_name = instance.component.name
    [{"/apps/#{component_name}", :dir}]
  end

  defp set_list_in_etcd(list, conn) do
    Enum.each(list, fn
      {name, :dir} ->
        try do
          #IO.puts "creating dir #{name}"
          Etcd.mkdir!(conn, name)
        rescue
          e in RuntimeError -> IO.puts "failed to mkdir #{name} #{inspect e}"
          e in Etcd.ServerError -> IO.puts "failed to mkdir #{name} #{inspect e}"
        end
      {key, :assign, value} ->
        try do
          #IO.puts "attomicallt setting #{key} => #{value}"
          Etcd.put_in!(conn, key, value)
        rescue
          e in RuntimeError -> IO.puts "failed to set key #{key} #{inspect e}"
          e in Etcd.ServerError -> IO.puts "failed to set key #{key} #{inspect e}"
        end
      {key, value} ->
        try do
          #IO.puts "creating setting #{key} => #{value}"
          Etcd.put!(conn, key, value)
        rescue
          e in RuntimeError -> IO.puts "failed to set key #{key} #{inspect e}"
          e in Etcd.ServerError -> IO.puts "failed to set key #{key} #{inspect e}"
        end
    end)
  end

  defp remove_list_in_etcd(list, conn) do
    Enum.each(list, fn
      {dir, :dir} ->
        #IO.puts "deleting dir #{dir}"
        try do
          Etcd.rmdir!(conn, dir)
        rescue 
          e in RuntimeError -> IO.puts "faileded to create directory? #{dir}: #{inspect e}"
          e in Etcd.ServerError -> IO.puts "faileded to create directory? #{dir}: #{inspect e}"
        end
      key ->
        try do
          Etcd.delete!(conn, key)
        rescue 
          e in RuntimeError -> IO.puts "faileded to delete #{key}? : #{inspect e}"
          e in Etcd.ServerError -> IO.puts "faileded to delete #{key}? : #{inspect e}"
        end
    end)
  end

  defp bound_port_for(%{} = empty, _insance) when empty in [%{}], do: ""
  defp bound_port_for(event, instance) do
    #IO.inspect event.ports
    port = case Enum.find(instance.component.publishes, fn(str) -> String.match?(str, ~r/PORT:/) end) do
      nil -> "80"
      pstring ->
        [_, number] = String.split(pstring, ":", parts: 2)
        number
    end
    #[{_, [%{"HostIp" => ip, "HostPort" => port}]} | _fuckthis ] = Map.to_list(event.ports)
    #if ip == "0.0.0.0", do: ip = Fulcrum.Settings.coreos_private_ipv4
    
    "#{instance.container_name}.fulcrum-nginx:#{port}"
  end
end

