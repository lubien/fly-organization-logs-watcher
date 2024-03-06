defmodule FlyNatsEx.DbConnection do
  use GenServer

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, [:ok], name: __MODULE__)
  end

  def init(_args) do
    database_path = Application.get_env(:fly_nats_ex, :database_path)
    {:ok, conn} = Exqlite.Sqlite3.open(database_path)
    {:ok, migrate(conn)}
  end

  def insert_log(log) do
    GenServer.cast(__MODULE__, {:insert, log})
  end

  def handle_cast({:insert, log}, conn) do
    {:ok, statement} =
      Exqlite.Sqlite3.prepare(conn, """
        insert into app_logs (
          datetime, message, level, app_name, machine, host, region, provider
        ) values (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)
      """)

    :ok =
      Exqlite.Sqlite3.bind(conn, statement, [
        DateTime.to_iso8601(log.datetime),
        log.message,
        log.level,
        log.app_name,
        log.machine,
        log.host,
        log.region,
        log.provider
      ])

    :done = Exqlite.Sqlite3.step(conn, statement)
    {:noreply, conn}
  end

  defp migrate(conn) do
    :ok =
      Exqlite.Sqlite3.execute(conn, """
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

    conn
  end
end
