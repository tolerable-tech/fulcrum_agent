defmodule AccompanimentManager.UnitFileTest do
  use ExUnit.Case

  import AccompanimentManager.UnitFile

  #@acciable_spec %AccompaniableSpecification{

  #}

  @opts %AccompanimentOptions{
    acc: TestAccOptions,
    request: %{"test" => "ing"},
    main: @acciable_spec

  }

  test "build/2" do
    #build(:service, )
  end
end
