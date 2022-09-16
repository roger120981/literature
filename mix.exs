defmodule Literature.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :literature,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      config_path: "./config/config.exs",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Literature.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.8"},
      {:jason, "~> 1.3", optional: true},
      {:slugy, "~> 4.1"},

      # Phoenix
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_live_view, "~> 0.17.11"},

      # Pagination
      {:scrivener_phoenix, "~> 0.3.2"},

      # Images
      {:waffle, "~> 1.1"},
      {:waffle_ecto, "~> 0.0.11"},
      {:waffle_gcs, "~> 0.2.0"},

      # Test
      {:floki, ">= 0.33.1", only: :test},
      {:credo, "~> 1.6", only: [:test, :dev], runtime: false},
      {:dialyxir, "~> 1.0", only: [:test, :dev], runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "test.ci": [
        "format --check-formatted",
        "deps.unlock --check-unused",
        "credo --strict",
        "test --raise",
        "dialyzer"
      ],
      "assets.watch": "cmd npm run watch --prefix assets",
      "assets.build": [
        "cmd npm run build --prefix assets",
        "phx.digest",
        "phx.digest.clean"
      ],
      publish: [
        "assets.build",
        "hex.publish"
      ]
    ]
  end
end
