#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Start the nginx service
# s6-overlay docs: https://github.com/just-containers/s6-overlay
# ==============================================================================
# shellcheck disable=SC2155

set -e

self_slug=$(bashio::addons "self" "addons.self.slug" '.slug')
self_repo_slug=${self_slug/_*/}
bashio::log.info "Repository slug: $self_repo_slug"

raw_new_addons="$(bashio::addons false "addons.list.new" ".addons[] | select(.slug | contains(\"_zigbee2mqtt\")) | select(.slug | endswith(\"_zigbee2mqtt_config_migrator\") | not) | select(.slug | startswith(\"$self_repo_slug\")) | .slug")"
new_addons="$(echo "$raw_new_addons" | sort | jq -R -s -c '[split("\n")[:-1] | .[] | select(length > 0)]')"
new_addons_count=$(echo "$new_addons" | jq length)
bashio::log.blue "Found $new_addons_count new Zigbee2MQTT add-on(s): $new_addons"

raw_old_addons="$(bashio::addons false "addons.list.old" ".addons[] | select(.slug | contains(\"_zigbee2mqtt\")) | select(.slug | startswith(\"$self_repo_slug\") | not) | .slug")"
old_addons="$(echo "$raw_old_addons" | sort | jq -R -s -c '[split("\n")[:-1] | .[] | select(length > 0)]')"
old_addons_count=$(echo "$old_addons" | jq length)
bashio::log.blue "Found $old_addons_count old Zigbee2MQTT add-on(s): $old_addons"

bashio::config.require 'data_path'

bashio::log.info "Starting Zigbee2MQTT config migration..."

z2m_config="$(bashio::config 'data_path')"

if [ ! -d "$z2m_config" ]; then
    bashio::exit.nok "Data path '$z2m_config' does not exist."
fi

new_addon_slug="$(bashio::config 'new_addon_slug')"

if [[ -z "$new_addon_slug" ]]; then
    if [ "$new_addons_count" -eq 1 ]; then
        new_addon_slug="$(echo "$new_addons" | jq -r '.[0]')"
        bashio::log.info "Found a single Zigbee2MQTT add-on '$new_addon_slug', using it..."
    else
        if [ "$new_addons_count" -eq 0 ]; then
            bashio::exit.nok "'new_addon_slug' config is empty. Cannot determine slug automatically: no new Zigbee2MQTT add-on is installed."
        else
            bashio::exit.nok "'new_addon_slug' config is empty. Cannot determine slug automatically: more than one new Zigbee2MQTT add-on is installed."
        fi
    fi
fi

# don't want the symlinks if they exist, Z2M will re-create as needed so can safely delete them
rm -fv "$z2m_config/external_converters/node_modules" "$z2m_config/external_extensions/node_modules"
rm -fv "/addon_configs/$new_addon_slug/external_converters/node_modules" "/addon_configs/$new_addon_slug/external_extensions/node_modules"

if [ -d "/addon_configs/$new_addon_slug" ]; then
    if [ "$(ls -A "/addon_configs/$new_addon_slug" | wc -l)" -ne 0 ]; then
        bashio::log.info "New addon_config folder is not empty, archiving it..."

        tar -czvf "/addon_configs/$new_addon_slug.dst-archive.tar.gz" "/addon_configs/$new_addon_slug"
        # do not use /* to remove content as that forces prompt with zsh
        rm -rfv "/addon_configs/$new_addon_slug"
        mkdir "/addon_configs/$new_addon_slug"
        mv "/addon_configs/$new_addon_slug.dst-archive.tar.gz" "/addon_configs/$new_addon_slug/dst-archive.tar.gz"
    fi
fi

if [ "$(ls -A "$z2m_config" | wc -l)" -ne 0 ]; then
    cp -R -d "$z2m_config/." "/addon_configs/$new_addon_slug"
    tar -czvf "/addon_configs/$new_addon_slug/src-archive.tar.gz" "$z2m_config"
    rm -rfv "$z2m_config"
else
    rm -rfv "$z2m_config"
    bashio::log.warning "'$z2m_config' is empty, nothing to migrate."
fi

if [ "$old_addons_count" -eq 1 ]; then
    old_addon_slug="$(echo "$old_addons" | jq -r '.[0]')"

    bashio::log.info "Uninstalling old addon $old_addon_slug..."
    bashio::addon.uninstall "$old_addon_slug"
fi

bashio::log.info "Successfully migrated to addon_config."
