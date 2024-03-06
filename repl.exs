alias FlyNatsEx.Logs
alias FlyNatsEx.Subscription

token = System.get_env("FLY_API_TOKEN")
{:ok, gnat} = Logs.start_link(token, "devsnorte")
{:ok, sub} = Subscription.start_link(gnat, %{}, self())

database_path = Application.get_env(:fly_nats_ex, :database_path)
{:ok, conn} = Exqlite.Sqlite3.open(database_path)
:ok = Exqlite.Sqlite3.execute(conn, """
  create table if not exists app_logs (
    id integer primary key,
    datetime datetime,
    message text,
    level text,
    app_name text,
    machine text,
    host text,
    region text,
    provider text
  )
""")

defmodule Repl do
  require Logger

  def loop(_conn, 0), do: :ok
  def loop(conn, limit) do
    receive do
      msg ->
        Logger.info(inspect(msg))
        insert_log(conn, msg)
        loop(conn, limit - 1)
    end
  end

  def insert_log(conn, log) do
    {:ok, statement} = Exqlite.Sqlite3.prepare(conn, """
      insert into app_logs (
        datetime, message, level, app_name, machine, host, region, provider
      ) values (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)
    """)
    :ok = Exqlite.Sqlite3.bind(conn, statement, [
      DateTime.to_iso8601(log.datetime),
      log.message,
      log.level,
      log.app_name,
      log.machine,
      log.host,
      log.region,
      log.provider
    ])

    # Step is used to run statements
    :done = Exqlite.Sqlite3.step(conn, statement)
  end
end

Repl.loop(conn, 500)
