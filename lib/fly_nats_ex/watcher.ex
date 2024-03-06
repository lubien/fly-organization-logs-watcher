defmodule FlyNatsEx.Watcher do
  use GenServer
  require Logger
  alias FlyNatsEx.Logs
  alias FlyNatsEx.DbConnection
  alias FlyNatsEx.Subscription

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, [:ok])
  end

  def init(_arg) do
    token = System.get_env("FLY_API_TOKEN")
    organization_slug = System.get_env("ORGANIZATION_SLUG")
    {:ok, gnat} = Logs.start_link(token, organization_slug)
    {:ok, sub} = Subscription.start_link(gnat, %{}, self())
    {:ok, sub}
  end

  def handle_info(log, state) do
    Logger.info(inspect(log))
    DbConnection.insert_log(log)

    {:noreply, state}
  end
end
