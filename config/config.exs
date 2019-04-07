# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Customize non-Elixir parts of the firmware.  See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.
config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.
config :shoehorn,
  init: [:nerves_runtime, :nerves_init_gadget, :runtime_tools, :nerves_leds],
  app: Mix.Project.config()[:app]

config :sprinkler, :auth_token, System.get_env("SPRINKLER_AUTH_TOKEN") || ""

config :sprinkler, Sprinkler.Socket,
  url: System.get_env("WEBSOCKET_ADDRESS") || "ws://127.0.0.1:4000/socket/websocket",
  serializer: Jason

config :sprinkler, :garage_doors, [
  %{name: "big", sensor_pin: 16},
  %{name: "small", sensor_pin: 12},
]

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
if Mix.target() != :host do
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

  config :tzdata, :data_dir, "/root/tzdata"
end
