# Home Assistant Add-on: Zigbee2MQTT config migrator

![Supports aarch64 Architecture](https://img.shields.io/badge/aarch64-yes-green.svg)
![Supports amd64 Architecture](https://img.shields.io/badge/amd64-yes-green.svg)
![Supports armhf Architecture](https://img.shields.io/badge/armhf-yes-green.svg)
![Supports armv7 Architecture](https://img.shields.io/badge/armv7-yes-green.svg)
![Supports i386 Architecture](https://img.shields.io/badge/i386-yes-green.svg)

Migrate the old `homeassistant_config` folder to the new `addon_configs` folder used by the new add-on.

## What it does

1. Lookup installed Zigbee2MQTT add-ons from old and new repositories
2. Check that `data_path` exists
3. If `new_addon_slug` is not supplied, check if a single new Zigbee2MQTT add-on is installed, and if so, use it, if none or more than one, abort
  - If supplied, use that
4. Remove `node_modules` symlinks if any
5. If new `addon_config` folder exists and is not empty, archive it
6. If `data_path` is not empty, migrate it, archive it, and remove it. If empty, just remove it.
7. If a single old Zigbee2MQTT add-on was found at step 1, uninstall it

See Documentation tab for more details.
