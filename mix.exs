defmodule Supplement.MixProject do
  use Mix.Project

  def project do
    [
      app: :capsule_supplement,
      description: "Supplemental storages and uploads for use with Capsule",
      version: "0.9.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: dialyzer(),
      name: "CapsuleSupplement",
      source_url: "https://github.com/elixir-capsule/supplement",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:capsule, github: "elixir-capsule/capsule"},
      {:ex_aws, "~> 2.0", optional: true},
      {:ex_aws_s3, "~> 2.0", optional: true},
      {:mox, "~> 1.0", only: [:test]},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:bypass, "~> 2.1", only: :test}
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      plt_add_apps: [:ex_aws_s3]
    ]
  end

  defp package do
    [
      maintainers: ["Thomas Floyd Wright"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/elixir-capsule/supplement"}
    ]
  end
end
