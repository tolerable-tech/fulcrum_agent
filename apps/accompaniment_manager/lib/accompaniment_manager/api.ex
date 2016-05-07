defmodule AccompanimentManager.Api do
  @fleet FleetApi.Direct

  alias AccompanimentManager.AccompaniableSpecification
  alias AccompanimentManager.AccompanimentOptions
  alias AccompanimentManager.UnitFile
  import AccompanimentOptions, only: [fleet_name: 2]

  def launch_all(instance) do
    acc_spec = AccompaniableSpecification.from(instance)
    instance.component.accompaniments
    |> Enum.map(&launch(&1, acc_spec))
  end

  def launch(acc, acc_spec = %AccompaniableSpecification{}) do
    AccompanimentOptions.for(acc, acc_spec)
    |> UnitFile.build
    |> send_to_fleet

    :ok
  end

  def remove_all(instance) do
    acc_spec = AccompaniableSpecification.from(instance)
    instance.component.accompaniments
    |> Enum.map(&remove(&1, acc_spec))
  end

  def remove(%{} = acc, acciable = %AccompaniableSpecification{}) do
    aopts = AccompanimentOptions.for(acc, acciable)
    Enum.each(aopts.unit_types, &delete_unit(fleet_name(&1, aopts)))
  end

  defp delete_unit(name) do
    @fleet.delete_unit(@fleet, name)
  end

  #defp start(uf) do
    #uf = %{uf | desiredState: ""}
    #@fleet.
  #end

  defp send_to_fleet(:skip), do: :ok
  defp send_to_fleet([]), do: :ok
  defp send_to_fleet([uf | rest]) do
    @fleet.set_unit(@fleet, uf.name, uf)
    send_to_fleet(rest)
  end
  defp send_to_fleet(uf) do
    @fleet.set_unit(@fleet, uf.name, uf)
    uf
  end
end
