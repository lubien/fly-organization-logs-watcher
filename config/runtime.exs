import Config

logs_dns_server = System.get_env("LOGS_DNS_SERVER")

config :fly_nats_ex,
       :logs_dns_server,
       if(logs_dns_server, do: to_charlist(logs_dns_server), else: ~c"fdaa::3")

config :fly_nats_ex,
       :database_path,
       System.get_env("DATABASE_PATH") || "priv/app_logs.db"

config :exqlite, default_chunk_size: 100
