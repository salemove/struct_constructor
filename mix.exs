defmodule StructConstructor.Mixfile do
  use Mix.Project

  def project do
    [
      app: :struct_constructor,
      version: "0.1.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      docs: [
        extras: ["README.md"],
        main: "readme"
      ]
    ]
  end

  def description do
    ~S"""
    StructConstructor allows you to declare structs using Ecto.Schema and generate
    constructor functions that will take care of coercion and handling various input
    formats (maps, keyword lists with string or atom keys).
    """
  end

  def package do
    [
      maintainers: ["SaleMove TechMovers"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/salemove/struct_constructor"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.0 or ~> 3.0"},
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end
end
