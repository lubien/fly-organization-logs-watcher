defmodule FlyNatsEx.Log do
  defstruct datetime: nil,
            message: nil,
            level: nil,
            app_name: nil,
            machine: nil,
            host: nil,
            region: nil,
            provider: nil

  def parse(json) when is_binary(json) do
    with {:ok, map} <- Jason.decode(json) do
      parse(map)
    end
  end

  def parse(%{
        "event" => %{"provider" => provider},
        "fly" => %{"app" => %{"instance" => machine, "name" => app_name}, "region" => region},
        "log" => %{"level" => level},
        "host" => host,
        "message" => message,
        "timestamp" => timestamp
      }) do
    {:ok, datetime, 0} = DateTime.from_iso8601(timestamp)

    shallow = %{
      app_name: app_name,
      machine: machine,
      region: region,
      host: host,
      level: level,
      message: message,
      datetime: datetime,
      provider: provider
    }

    struct(__MODULE__, shallow)
  end
end
