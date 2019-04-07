defmodule Sprinkler.MixProject do
  use Mix.Project

  @all_targets [:rpi0, :rpi3, :rpi]

  def project do
    [
      app: :sprinkler,
      version: "0.1.0",
      elixir: "~> 1.8",
      archives: [nerves_bootstrap: "~> 1.0"],
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.target() != :host,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps()
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Sprinkler.Application, []},
      extra_applications: [:logger, :runtime_tools, :ssl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.1"},
      {:phoenix_channel_client, "~> 0.4"},
      {:nerves, "~> 1.4", runtime: false},
      {:sched_ex, "~> 1.0"},
      {:shoehorn, "~> 0.4"},
      {:websocket_client, "~> 1.3"},
      {:elixir_ale, "~> 1.0", targets: @all_targets},
      {:nerves_leds, "~> 0.8", targets: @all_targets},
      {:nerves_runtime, "~> 0.6", targets: @all_targets},
      {:nerves_init_gadget, "~> 0.4", targets: @all_targets},
      {:nerves_time, "~> 0.2", targets: @all_targets},
      {:nerves_system_rpi, "~> 1.5", runtime: false, targets: :rpi},
      {:nerves_system_rpi0, "~> 1.5", runtime: false, targets: :rip0},
      {:nerves_system_rpi2, "~> 1.5", runtime: false, targets: :rpi2},
      {:nerves_system_rpi3, "~> 1.5", runtime: false, targets: :rpi3},
      {:nerves_system_rpi3a, "~> 1.5", runtime: false, targets: :rpi3a},
      {:nerves_system_bbb, "~> 2.0", runtime: false, targets: :bbb},
      {:nerves_system_x86_64, "~> 1.5", runtime: false, targets: :x86_64},
    ]
  end
end
