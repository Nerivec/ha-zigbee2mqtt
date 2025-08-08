# Home Assistant Add-on: Zigbee2MQTT config migrator

## How to use

- Install the new Zigbee2MQTT add-on
- [Optional] Navigate to the newly installed Zigbee2MQTT add-on and take note of its URL:
  - `[...]/hassio/addon/abcd1234_zigbee2mqtt/info`
    - you will need to enter `abcd1234_zigbee2mqtt` in the next step for `new_addon_slug`
- Set the appropriate data in the add-on configuration tab
- Start the add-on
- The process will execute and the add-on will automatically stop
- Check the add-on `Log` tab to make sure no error occured
- You can now uninstall the Zigbee2MQTT config migrator add-on and the old Zigbee2MQTT add-on and remove the old repository from the add-on store

> [!IMPORTANT]
> Make sure to update the settings on the add-on configuration page as needed (e.g. socat) before starting the new add-on.

> [!TIP]
> If new add-on `addon_config` folder is not empty, it is archived and emptied before migrating.
> It will be named `dst-archive.tar.gz` and placed in the new `addon_config` folder.

> [!TIP]
> `data_path` folder is archived after migrating for good measure.
> It will be named `src-archive.tar.gz` and placed in the new `addon_config` folder.
> ⚠️ `data_path` is always removed on successful migration to prevent misuse, the old Zigbee2MQTT add-on will also be uninstalled (if a single one is present, else you will have to do it manually).

> [!TIP]
> You can also remove the old repository from the add-on store, and uninstall the config migrator add-on.
