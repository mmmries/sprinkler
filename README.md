# Sprinkler

A project for the remote nerve meetup

## How To Get Your Project Started

Initialize a nerves project with a command like: `mix nerves.new sprinkler`.
Now make modifications of adding `nerves_init_gadget` like [this](https://github.com/mmmries/sprinkler/compare/db25c00ced4eb1a627373c2b2229df67ac303887...bab60a8947c9142ef5987b1a0c86003eb320403b).

## Burn The Initial Image

Mount your MicroSD card to the host machine and run a command like:

```
MIX_TARGET=rpi3 NERVES_NETWORK_SSID=MyWiFi NERVES_NETWORK_PSK=MyPassword mix do deps.get, firmware, firmware.burn
```

Confirm that it's burning to the correct disk and follow the prompts to burn the image.
Now put the MicroSD into your raspberry pi 3 and power it up.
Within a few seconds you should be able to run `ping sprinkler.local` from your host machine and see that it gets ping results back.

## How To Push Updates

Once your device is up and running on your wifi you can push subsequent updates to the device with a command like:

```
MIX_TARGET=rpi3 NERVES_NETWORK_SSID=MyWiFi NERVES_NETWORK_PSK=MyPassword mix do firmware, firmware.push sprinkler.local
```
