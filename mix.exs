defmodule FlyNatsEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :fly_nats_ex,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: true,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {FlyNatsEx.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gnat, git: "https://github.com/lubien/nats.ex.git"},
      {:jason, "~> 1.4"},
      {:exqlite, "~> 0.17"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
