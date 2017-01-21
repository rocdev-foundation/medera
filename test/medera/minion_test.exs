defmodule Medera.MinionTest do
  use ExUnit.Case

  alias Medera.Minion

  test "master_node is able to parse a string" do
    value_before = Application.get_env(:medera, :master_node)
    Application.put_env(:medera, :master_node, "foo@bar")
    assert :foo@bar == Minion.master_node()
    Application.put_env(:medera, :master_node, value_before)
  end

  test "the registry is only run on the master node" do
    children = Minion.Supervisor.child_specs(false)
    assert [{Medera.Minion.Connection, _, _, _, _, _}] = children
  end

  test "minion detects disconnect and reconnects" do
    :ok = Patiently.wait_for(fn -> :minion@localhost in Medera.Minion.list end)
    assert Node.self() in Minion.list
    assert :minion@localhost in Minion.list

    Node.disconnect(:minion@localhost)
    :ok = Patiently.wait_for(
       fn -> length(Medera.Minion.list) == 1 end,
       dwell: 10
     )
    refute :minion@localhost in Minion.list

    :ok = Patiently.wait_for(fn -> :minion@localhost in Medera.Minion.list end)
    assert Node.self() in Minion.list
    assert :minion@localhost in Minion.list
  end
end
