defmodule AccompanimentManager.UnitFile do
  use AccompanimentManager.UnitBuilder

  def build(:skip), do: :skip
  def build(opts) do
    Enum.map(opts.unit_types, fn(unit_type) -> 
      build(unit_type, opts)
    end)
  end
  def build(unit_type, opts) do
    %Unit{
      name: fleet_name(unit_type, opts),
      desiredState: desired_state(unit_type, opts),
      options: build_options(opts, opts.unit_stanzas[unit_type], unit_type)
    }
  end

  def build_options(opts, list, unit_type) do
     Enum.map(list, fn
       ({stanza, value}) -> build_option(value, stanza)
       (stanza) -> dispatch(opts, stanza, unit_type)
    end) |> List.flatten
  end

  def dispatch(opts, stanza, unit_type) do
    apply(opts.acc, stanza, [unit_type, opts])
    |> build_option(stanza)
  end

  def build_option(list, stanza) when is_list(list) do
    Enum.map(list, fn(val) -> build_option(val, stanza) end)
  end
  def build_option(value, stanza), do: option(stanza, value)
end
      #options: [
        #unit_option("Description", description_for(:s3_backup, instance)),
        #unit_option("Requires", instance_service_name(instance)),
        #unit_option("After", instance_service_name(instance)),
        #service_option("User", "core"),
        #service_option("ExecStartPre", "/usr/bin/docker pull #{@s3_acc_image}"),
        #service_option("ExecStart", start_cmd_for(:s3_backup, instance)),
        ##install_option("WantedBy", "local.target")
      #]
        #unit_option("Description", "Runs #{service_unit.name} every hour."),
        #unit_option("After", instance_service_name(instance)),
        #unit_option("Requires", instance_service_name(instance)),
        #timer_option("OnCalendar", "hourly"),
        #timer_option("Persistent", "true"),
