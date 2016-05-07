defmodule AccompanimentManager.UnitBuilder do

  defmodule BuilderFunctions do
    @options [
      user:              {"Service", "User"},
      type:              {"Service", "Type"},
      conflicts:         {"X-Fleet", "Conflicts"},
      stop:              {"Service", "ExecStop"},
      start_post:        {"Service", "ExecStartPost"},
      start:             {"Service", "ExecStart"},
      start_pre:         {"Service", "ExecStartPre"},
      env_file:          {"Service", "EnvironmentFile"},
      kill_mode:         {"Service", "KillMode"},
      timeout_start_sec: {"Service", "TimeoutStartSec"},
      start_after:       {"Unit", "After"},
      requires:          {"Unit", "Requires"},
      description:       {"Unit", "Description"},
      on_calendar:       {"Timer", "OnCalendar"},
      persistent:        {"Timer", "Persistent"}
    ]

    def unit_option(name, value) do
      option("Unit", name, value)
    end

    def service_option(name, value) do
      option("Service", name, value)
    end

    def install_option(name, value) do
      option("Install", name, value)
    end

    def timer_option(name, value) do
      option("Timer", name, value)
    end

    def option(unit, name, value) do
      %FleetApi.UnitOption{section: unit, name: name, value: value}
    end
    def option(name, value) do
      IO.inspect name
      {section, name} = Dict.get(@options, name)
      option(section, name, value)
    end
  end

  defmacro __using__(opts) do
    quote do
      alias FleetApi.Unit 
      alias FleetApi.UnitOption
      alias Fulcrum.DataStore

      alias AccompanimentManager.AccompanimentOptions
      import AccompanimentOptions, only: [fleet_name: 2, desired_state: 2]

      import AccompanimentManager.UnitBuilder.BuilderFunctions
    end
  end

end
