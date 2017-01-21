defmodule MederaTest do
  use ExUnit.Case
  doctest Medera

  test "supervisor children does not include web when in minion mode" do
    children = Medera.child_specs(false)
    assert [{Medera.Minion.Supervisor, _, _, _, _, _}] = children
  end
end
