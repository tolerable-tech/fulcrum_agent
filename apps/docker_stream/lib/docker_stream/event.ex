defmodule DockerStream.Event do
  defstruct(type: nil, id: "", name: "",
            ip: "", ports: [], time: nil)
end
