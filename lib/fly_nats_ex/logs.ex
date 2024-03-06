defmodule FlyNatsEx.Logs do
  def start_link(auth_token, organization_slug) do
    dns_server = Application.get_env(:fly_nats_ex, :logs_dns_server)

    params = %{
      host: dns_server,
      port: 4223,
      username: organization_slug,
      password: auth_token,
      tcp_opts: [:binary, :inet6],
      auth_required: true
    }

    Gnat.start_link(params)
  end
end
