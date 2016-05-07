defmodule AccompanimentManager.AccompanimentOptions.EctoMigrator do
  alias AccompanimentManager.AccompanimentOptions
  @behaviour AccompanimentOptions

  @docker_bin "/usr/bin/docker"
  @ecto_migrator_image "bossdjbradley/ecto_migrator"
  @fleet_bin "/usr/bin/fleetctl"

  # CALLBACKS

  def init(req, acc_spec) do
    %AccompanimentOptions{
      acc: __MODULE__,
      request: req,
      main: acc_spec,
      unit_stanzas: %{
        service: [:description, :requires, :start_after, {:user, "core"},
          {:type, "oneshot"}, :start_pre, :start]
      },
      unit_types: [:service]
    }
  end

  def fleet_name(:service, opt) do
    "O#{opt.main.owner_id}-ecto_migrator-#{opt.main.component_name}.service"
  end

  def desired_state(_uf, %{} = _opt) do
    "launched"
  end

  def description(:service, %{} = opt) do
    "Ecto Migration runner for #{opt.main.fleet_name}."
  end

  def requires(:service, %{} = opt) do
    opt.main.fleet_name
  end

  def start_after(:service, opt) do
    opt.main.fleet_name
  end

  def start_pre(:service, _opt) do
    ["#{@docker_bin} pull #{@ecto_migrator_image}", "/usr/bin/sleep 3"]
  end

  def start(:service, %{} = opt) do
    "#{@docker_bin} run --rm #{env_string(opt)}" <> " #{link_string(opt)}" <>
      " #{net_string(opt)} #{@ecto_migrator_image}"
  end

  def stop(:service, opt) do
    "#{@fleet_bin} destroy #{fleet_name(:service, opt)}"
  end

  # IMPL

  def env_string(%{} = opt) do
    "-e REPO=#{opt.request["migration_repo"]}" <> \
    " -e PG_PASS=#{Map.get(opt.request, "password")} -e PG_USER=#{Map.get(opt.request, "user")}" <> \
    " -e PG_DB=#{Map.get(opt.request, "database")} -e PG_URL=#{Map.get(opt.request, "url")}"
  end

  def link_string(%{} = opt) do
    if Map.get(opt.request, "url") do
      ""
    else
      " --link #{opt.main.container_name}:" <>
        "#{opt.main.component_name}.fulcrum "
    end
  end

  def net_string(%{} = opt) do
    if (url = Map.get(opt.request, "url")) do
      "--net #{String.split(url, ".") |> List.last}"
    else
      ""
    end
  end

end
