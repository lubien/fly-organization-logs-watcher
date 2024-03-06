defmodule FlyNatsEx.Subscription do
  use GenServer
  alias FlyNatsEx.Log
  require Logger

  def start_link(gnat, scope, parent, opts \\ []) do
    GenServer.start_link(__MODULE__, [gnat, scope, parent], opts)
  end

  def init([gnat, scope, parent]) do
    {:ok, subscription} = subscribe(gnat, self(), scope)

    {:ok,
     %{
       subscription: subscription,
       parent: parent
     }}
  end

  def handle_info({:msg, %{body: json}}, %{parent: parent} = state) do
    send(parent, Log.parse(json))
    {:noreply, state}
  end

  def subscribe(gnat, pid, opts) do
    subject = nats_subject(opts)
    Gnat.sub(gnat, pid, subject)
  end

  def nats_subject(%{app_name: app_name, region: region, instance: instance}) do
    "logs.#{app_name}.#{region}.#{instance}"
  end

  def nats_subject(%{app_name: app_name, region: region}) do
    "logs.#{app_name}.#{region}.>"
  end

  def nats_subject(%{app_name: app_name, instance: instance}) do
    "logs.#{app_name}.*.#{instance}"
  end

  def nats_subject(%{app_name: app_name}) do
    "logs.#{app_name}.>"
  end

  def nats_subject(_opts) do
    "logs.>"
  end
end
