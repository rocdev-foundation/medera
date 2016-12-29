use Mix.Config

defmodule TestConfigHelper do
  def db_url do
    System.get_env("MEDERA_DB_URL") ||
      "postgres://postgres:postgres@localhost/medera_test"
  end
end

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :medera, Medera.Endpoint,
  http: [port: 4001],
  server: false

config :medera,
  slack_api_token: "test_token",
  connector: Medera.Support.TestConnector

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :medera, Medera.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: TestConfigHelper.db_url,
  pool: Ecto.Adapters.SQL.Sandbox
