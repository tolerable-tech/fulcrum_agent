defmodule AccompanimentManager.AccompanimentOptions.S3Backup do
  alias Fulcrum.DataStore
  alias AccompanimentManager.AccompanimentOptions
  @behaviour AccompanimentOptions

  @docker_bin "/usr/bin/docker"
  @s3_acc_image "bossdjbradley/s3_accompaniment"

  def init(request, acc_spec) do
    %AccompanimentOptions{
      acc: __MODULE__,
      request: request,
      main: acc_spec,
      unit_stanzas: %{
        service: [:description, :requires, :start_after, {:user, "core"},
         :start_pre, :start],
        timer: [:description, :start_after, :requires, {:on_calendar, "hourly"},
          {:persistent, "true"}]
      },
      unit_types: [:service, :timer]
    }
  end

  def fleet_name(:service, opt) do
    "O#{opt.main.owner_id}-s3_backup-#{opt.main.component_name}.service"
  end
  def fleet_name(:timer, opt) do
    "O#{opt.main.owner_id}-s3_backup-#{opt.main.component_name}.timer"
  end

  def desired_state(:service, %AccompanimentOptions{} = _opt) do
    "loaded"
  end
  def desired_state(:timer, %AccompanimentOptions{} = _opt) do
    "launched"
  end

  def description(:service, opts) do
    "Backup #{opts.main.component_name} volumes to S3."
  end
  def description(:timer, opts) do
    "Launch timer for Backup #{opts.main.component_name} volumes to S3."
  end

  def requires(_unit_file, opts) do
    opts.main.fleet_name
  end

  def start_after(_unit_file, opts) do
    opts.main.fleet_name
  end

  def start_pre(:service, _opt) do
    "#{@docker_bin} pull #{@s3_acc_image}"
  end

  def start(:service, %AccompanimentOptions{} = opt) do
    "#{@docker_bin} run #{env_string(opt)} --rm" <>
      " #{volumes_from_line(opt)} #{@s3_acc_image}"
  end

  # IMPL

  defp env_string(%AccompanimentOptions{} = opt) do
    aws_creds = DataStore.Credentials.for(:s3, opt)

    ["", "AWS_ACCESS_KEY_ID=#{aws_creds.id}",
     "AWS_SECRET_ACCESS_KEY=#{aws_creds.secret}",
     "AWS_DEFAULT_REGION=#{aws_creds.region}",
     "DATA_VOLUME=#{opt.request["volumes"]}",
     "S3_BUCKET=#{bucket_for(opt)}",
     "COMPONENT_PATH=#{opt.main.component_name}/#{opt.main.owner_id}/#{opt.main.instance_id}"] |> Enum.join(" -e ")
  end

  defp volumes_from_line(%AccompanimentOptions{} = opt) do
    "--volumes-from #{opt.main.container_name}"
  end

  # FIXME: where are we getting this?
  defp bucket_for(_ins), do: "db.rn.backup"

end
