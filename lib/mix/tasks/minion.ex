defmodule Mix.Tasks.Minion do
  @moduledoc false

  # these tasks should only be called by scripts

  defmodule Start do
    @moduledoc false

    use Mix.Task

    @shortdoc "Start a medera minion - use scripts/start_minion.sh"

    require Logger

    def run(_) do
      {:ok, _} = Application.ensure_all_started(:medera)
      Logger.info("Minion #{inspect Node.self()} started")
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
      minion = String.to_atom(minion_name)
      true = Node.connect(minion)
      :rpc.call(minion, :init, :stop, [])
    end
  end
end
