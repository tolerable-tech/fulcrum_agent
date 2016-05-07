defmodule AccompanimentManager.AccompaniableSpecification do
  @type t :: %__MODULE__{
    instance_id: non_neg_integer,
    owner_id: non_neg_integer,
    fleet_name: binary,
    container_name: binary,
    component_name: binary
  }

  defstruct([instance_id: 0, owner_id: 0, fleet_name: "", container_name: "", component_name: ""])

  def from(ins = %{}) do
    %__MODULE__{
      instance_id: ins.id,
      owner_id: ins.owner_id,
      fleet_name: ins.fleet_name,
      container_name: ins.container_name,
      component_name: ins.component.name
    }
  end
end
