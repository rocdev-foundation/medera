defmodule Mix.Tasks.Minion do
  @moduledoc false

  # These mix tasks are basically simple scripts to make it easy to control a
  # minion from the command line.  They require a particular invocation wrt
  # environment variables and command-line arguments and thus should be
  # launched using the companion scripts in the scripts directory.

  defmodule Start do
    @moduledoc false

    use Mix.Task

    @shortdoc "Start a medera minion - use scripts/start_minion.sh"

    require Logger

    def run(_) do
      # launch the medera application
      {:ok, _} = Application.ensure_all_started(:medera)
      Logger.info("Minion #{inspect Node.self()} started")

      # should block indefinitely
      receive do
        msg ->
          Logger.info(
            "Minion #{inspect Node.self()} stopping because it received " <>
            "message #{inspect msg}"
          )
      end
    end
  end

  defmodule Stop do
    @moduledoc false

    use Mix.Task

    @shortdoc "Stop a medera minion - use scripts/stop_minion.sh"

    require Logger

    def run([minion_name]) do
      # stops a minion by connecting to it and issuing a shutdown command via
      # rpc
      minion = String.to_atom(minion_name)
      true = Node.connect(minion)
      :rpc.call(minion, :init, :stop, [])
    end
  end
end
