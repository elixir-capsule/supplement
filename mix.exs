defmodule Supplement.MixProject do
  use Mix.Project

  def project do
    [
      app: :capsule_supplement,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: dialyzer()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ex_aws, :ex_aws_s3]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:capsule, "~> 0.6"},
      {:ex_aws, "~> 2.0", optional: true},
      {:ex_aws_s3, "~> 2.0", optional: true},
      {:mox, "~> 1.0", only: [:test]},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end
end
