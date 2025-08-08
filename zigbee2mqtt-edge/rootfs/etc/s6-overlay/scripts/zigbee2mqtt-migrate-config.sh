#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Start the nginx service
# s6-overlay docs: https://github.com/just-containers/s6-overlay
# ==============================================================================
# shellcheck disable=SC2155

set -e

z2m_config="$(bashio::config 'data_path')"

if bashio::var.is_empty "$z2m_config"; then
    bashio::log.info "data_path is unspecified. No migration necessary."

    bashio::exit.ok
fi

if bashio::var.equals "$z2m_config" "/addon_config" || bashio::var.equals "$z2m_config" "/addon_config/";then
    bashio::log.info "data_path is already '/addon_config'. No migration necessary."
    bashio::log.magenta "You have already migrated to addon_config, you can remove the add-on configuration 'data_path' to stop seeing this message."

    bashio::exit.ok
fi

if ! bashio::fs.directory_exists "$z2m_config"; then
    bashio::log.info "data_path '$z2m_config' does not exist. No migration necessary."
    bashio::log.magenta "You have already migrated to addon_config, you can remove the add-on configuration 'data_path' to stop seeing this message."

    bashio::exit.ok
fi

if [[ "$(ls -A "$z2m_config" | wc -l)" -ne 0 ]]; then
    bashio::log.info "data_path '$z2m_config' is empty. No migration necessary."
    bashio::log.magenta "You have already migrated to addon_config, you can remove the add-on configuration 'data_path' to stop seeing this message."

    rm -rfv "$z2m_config"
    bashio::exit.ok
fi

bashio::log.info "Starting Zigbee2MQTT config migration..."

# don't want the symlinks if they exist, Z2M will re-create as needed so can safely delete them
rm -fv "$z2m_config/external_converters/node_modules" "$z2m_config/external_extensions/node_modules"
rm -fv "/addon_config/external_converters/node_modules" "/addon_config/external_extensions/node_modules"

if [[ $z2m_config == /addon_config/* ]]; then
    bashio::log.info "data_path is nested under addon_config folder. Skipping dst archiving..."
else
    if [[ "$(ls -A "/addon_config" | wc -l)" -ne 0 ]]; then
        bashio::log.info "New addon_config folder is not empty, archiving it..."

        tar -czvf "/addon_config.dst-archive.tar.gz" "/addon_config"
        # do not use /* to remove content as that forces prompt with zsh
        rm -rfv "/addon_config"
        mkdir "/addon_config"
        mv "/addon_config.dst-archive.tar.gz" "/addon_config/dst-archive.tar.gz"
    fi
fi

cp -R -d "$z2m_config/." "/addon_config"
tar -czvf "/addon_config/src-archive.tar.gz" "$z2m_config"
rm -rfv "$z2m_config"

bashio::log.info "Successfully migrated to addon_config."
bashio::log.magenta "You can now remove the add-on configuration 'data_path'."
