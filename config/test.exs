use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sulat, Sulat.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :sulat, Sulat.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "sulat_dev",
  password: "sulat_dev",
  database: "sulat_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# ease up the hashing rounds
config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2, 1
