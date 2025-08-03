# Home Assistant Add-on: Zigbee2MQTT

[![Builder](https://github.com/Nerivec/ha-zigbee2mqtt/actions/workflows/builder.yaml/badge.svg)](https://github.com/Nerivec/ha-zigbee2mqtt/actions/workflows/builder.yaml)
![Supports aarch64 Architecture](https://img.shields.io/badge/aarch64-yes-green.svg)
![Supports amd64 Architecture](https://img.shields.io/badge/amd64-yes-green.svg)
![Supports armhf Architecture](https://img.shields.io/badge/armhf-yes-green.svg)
![Supports armv7 Architecture](https://img.shields.io/badge/armv7-yes-green.svg)
![Supports i386 Architecture](https://img.shields.io/badge/i386-yes-green.svg)

> [!IMPORTANT]
> Currently in testing.

Zigbee2MQTT Home Assistant add-ons.

This is a refactoring of https://github.com/zigbee2mqtt/hassio-zigbee2mqtt with the following (major) changes:
- Rewrite to use s6-overlay & co, and improve configuration handling
- ⚠️ BREAKING: Use `addon_config` mapping. See [migration](#migrating-from-official-add-on)
  - Config folder is now included in Home Assistant add-on backups
  - Each add-on now has its own config folder (if wanting to switch between regular and edge add-ons, you must copy over the data)
  - The toggle to delete the add-on data when uninstalling the add-on will now remove your Zigbee2MQTT configuration (yaml, db, logs, etc.)
- All `configuration.yaml` settings are now handled either through the onboarding (can be forced in add-on configuration tab), the frontend once Zigbee2MQTT has started, or directly in the file itself (using add-on) while Zigbee2MQTT is stopped
- The [Zigbee2MQTT watchdog](https://www.zigbee2mqtt.io/guide/installation/15_watchdog.html) is now enabled by default, with `default` settings
- For easier debugging (advanced), can now override app code through `app_overrides` folder in add-on config folder
  - On add-on start, if the `app_overrides` folder exists, its content is copied over the Zigbee2MQTT app folder (using exact folder structure)
  - Deleting the `app_overrides` folder will remove any override on next add-on start

## Installing this repository in your add-on store

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FNerivec%2Fha-zigbee2mqtt)

For more details: https://www.home-assistant.io/common-tasks/os#installing-a-third-party-add-on-repository

## Migrating from official add-on

If you are migrating an existing installation from https://github.com/zigbee2mqtt/hassio-zigbee2mqtt you will need to move your `configuration.yaml` (& logs if wanted).

- Install the add-on, (check the add-on configuration page if anything needs changing for your setup)
- Install, start and open the [Studio Code Server add-on](https://www.home-assistant.io/common-tasks/os/#installing-and-using-the-visual-studio-code-vsc-add-on) from the add-on store
- In Menu > File > Add folder to workspace, select the `addon_configs` folder and add it
- After the interface is done reloading, you should then see both the `config` and the `addon_configs` folders
- If the appropriate `*_zigbee2mqtt*` folder does not exist, you must create it
  - You can get the exact name the folder should have by navigating to the add-on page and taking note of the URL:
    - Example URL: `http://homeassistant.local:8123/hassio/addon/abcd1234_zigbee2mqtt_edge/info`
    - Example folder name: `abcd1234_zigbee2mqtt_edge`
    - ⚠️ Be sure to take the right add-on if you have multiple Zigbee2MQTT installed
- Move the contents of the `config/zigbee2mqtt` folder to the previously identified folder in `addon_configs`
  - You should end up with something like this (uses example folder name from above):
    - `addon_configs`
      - `abcd1234_zigbee2mqtt_edge`
        - `log`
        - `configuration.yaml`
        - `coordinator_backup.json`
        - `database.db`
        - `database.db.backup`
        - `state.json`
- Go back to the add-on and start it

If, after this, Zigbee2MQTT keeps showing the onboarding page on start, check the above steps again.
