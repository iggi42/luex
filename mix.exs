defmodule Luex.MixProject do
  use Mix.Project

  @source_url "https://github.com/iggi42/luex"

  def project do
    [
      app: :luex,
      version: "0.0.1",
      elixir: "~> 1.17",
      docs: docs(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      source_url: @source_url,
      description: "an elixir interface to the great luerl",
      package: [
        licenses: ["Apache-2.0"],
        maintainers: ["iggi42"],
        files: ["lib", "mix.exs", "README.md", "LICENSE"],
        links: %{ "GitHub" => @source_url }
      ]
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
      {:luerl, "~> 1.2"},

      # development tools
      {:credo, "~> 1.7", runtime: false, only: [:dev, :test], override: true},
      {:dialyxir, "~> 1.4", runtime: false, only: [:dev]},
      {:ex_doc, ">= 0.0.0", runtime: false, only: [:dev]}

      # CI Test Reports
      # {:junit_formatter, "~> 3.3", runtime: false, only: [:test]}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      source_ref: "master",
      before_closing_head_tag: fn
        :html ->
          "<script src=\"https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js\"></script>"

        _ ->
          ""
      end,
      before_closing_body_tag: fn
        :html ->
          """
          <script>
            mermaid.initialize({
              startOnLoad: true
            })
          </script>
          <style>
            .abstract .classTitle {
              font-style: italic;
            }
          </style>
          """

        _ ->
          ""
      end
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:mix],
      # Store the plts somewhere easy to cache, including shared plts
      # Hardcoding 'dev' here is ok, since dialyxir is `only: :dev`
      plt_core_path: "_build/dev/"
    ]
  end
end
