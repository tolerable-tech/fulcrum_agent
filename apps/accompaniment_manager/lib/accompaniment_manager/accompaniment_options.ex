defmodule AccompanimentManager.AccompanimentOptions do
  use Behaviour

  @type unit_types :: :service | :timer

  @type t :: %__MODULE__{
    acc: module,
    request: %{binary => any},
    main: AccompanimentManager.AccompaniableSpecification.t,
    options: %{atom => any},
    unit_stanzas: %{unit_types => []},
    unit_types: [unit_types]
  }

  defstruct([acc: nil, request: %{}, main: nil, options: %{},
    unit_stanzas: %{}, unit_types: []])

  @callback init(%{}, AccompanimentManager.AccomapniableSpecification.t) :: t

  @callback fleet_name(unit_types, t) :: String.t

  @callback desired_state(unit_types, t) :: String.t

  @callback description(unit_types, t) :: String.t

  @callback requires(unit_types, t) :: String.t

  @callback start_after(unit_types, t) :: String.t

  @callback start(unit_types, t) :: String.t

  #@callback exec_stop(unit_types, t) :: String.t

  def for(req = %{"type" => "s3_backup"}, acc_spec) do
    case Fulcrum.DataStore.Credentials.available_for(:s3, acc_spec) do
      true -> AccompanimentManager.AccompanimentOptions.S3Backup.init(req, acc_spec)
      false -> :skip
    end
  end
  def for(req = %{"type" => "ecto_migrator"}, acc_spec) do
    AccompanimentManager.AccompanimentOptions.EctoMigrator.init(req, acc_spec)
  end
  #def for(:s3_backup, ins) do
    #AccompanimentManager.AccompanimentOptions.S3Backup.init(req, ins)
  #end
  #def for(:ecto_migrator, ins) do
    #AccompanimentManager.AccompanimentOptions.EctoMigrator.init(req, ins)
  #end

  # delegators

  def fleet_name(unit_type, opts), do: opts.acc.fleet_name(unit_type, opts)
  def desired_state(unit_type, opts), do: opts.acc.desired_state(unit_type, opts)
  #def description(opts), do: opts.acc.description(opts)
  #def requires(opts), do: opts.acc.requires(opts)
  #def after(opts), do: opts.acc.after(opts)
  #def exec_start(opts), do
end
