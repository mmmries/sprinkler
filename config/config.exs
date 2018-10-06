# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

target = Mix.Project.config()[:target]

name = System.get_env("SPRINKLER_NAME") || "example"
auth_token = System.get_env("SPRINKLER_AUTH_TOKEN") || ""

# Customize non-Elixir parts of the firmware.  See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.
config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.
config :shoehorn,
  init: [:nerves_runtime, :nerves_init_gadget, :runtime_tools, :nerves_leds],
  app: Mix.Project.config()[:app]

config :sprinkler, :auth, %{
    name:       name,
    auth_token: auth_token,
  }

config :sprinkler, :gnat_connection, %{
    name: :gnat,
    connection_settings: [
      %{
        host: System.get_env("NATS_HOST") || "localhost",
        port: (System.get_env("NATS_PORT") || "4222") |> String.to_integer(),
        tls:  (System.get_env("NATS_TLS") || "false") |> String.to_atom(),
        username: System.get_env("NATS_USER"),
        password: System.get_env("NATS_PASS")
      },
    ]
  }

config :sprinkler, :gnat_consumer, %{
    connection_name: :gnat,
    consuming_function: {Sprinkler.Command, :decode},
    subscription_topics: [
      %{topic: "sprinkler.commands.#{name}", queue_group: "sprinkler.commands.#{name}"},
    ],
  }

config :sprinkler, :valves, [
  %{pin:  4, name: "zone1"},
  %{pin: 17, name: "zone2"},
  %{pin: 18, name: "zone3"},
  %{pin: 27, name: "zone4"},
  %{pin: 22, name: "zone5"},
  %{pin: 23, name: "zone6"},
  %{pin: 24, name: "zone7"},
  %{pin: 25, name: "zone8"},
]

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations
if target != "host" do
  config :nerves_firmware_ssh,
    authorized_keys: [
      File.read!(Path.join(System.user_home!(), ".ssh/id_rsa.pub"))
    ]

  config :logger, backends: [RingLogger]

  config :nerves_init_gadget,
    ifname: "wlan0",
    address_method: :dhcp,
    mdns_domain: "sprinkler.local",
    node_name: "sprinkler",
    node_host: :mdns_domain,
    ssh_console_port: 22

  key_mgmt = System.get_env("NERVES_NETWORK_KEY_MGMT") || "WPA-PSK"

  config :nerves_network, :default,
    wlan0: [
      ssid: System.get_env("NERVES_NETWORK_SSID"),
      psk: System.get_env("NERVES_NETWORK_PSK"),
      key_mgmt: String.to_atom(key_mgmt)
    ]

  config :nerves_leds, names: [status: "led0"]

  config :nerves_time, :servers, [
    "0.us.pool.ntp.org",
    "1.us.pool.ntp.org",
    "2.us.pool.ntp.org",
    "3.us.pool.ntp.org",
  ]
end
