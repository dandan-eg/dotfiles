#!/usr/bin/env bash
set -euo pipefail

# Script to install or update Herdr plugins defined in plugins.json
# Usage: ./herdr-plugin-installer.sh

PLUGINS_JSON="${HERDR_PLUGINS_JSON:-$HOME/dev/dotfiles/herdr/plugins.json}"

if [ ! -f "$PLUGINS_JSON" ]; then
    echo "Error: plugins.json not found at $PLUGINS_JSON" >&2
    exit 1
fi

# Get the number of plugins
PLUGIN_COUNT=$(jq '. | length' "$PLUGINS_JSON")

if [ "$PLUGIN_COUNT" -eq 0 ]; then
    echo "No plugins to install."
    exit 0
fi

echo "Found $PLUGIN_COUNT plugin(s) in $PLUGINS_JSON"

# Loop through each plugin
for ((i=0; i<PLUGIN_COUNT; i++)); do
    PLUGIN=$(jq -c ".[$i]" "$PLUGINS_JSON")
    
    PLUGIN_ID=$(echo "$PLUGIN" | jq -r '.plugin_id')
    PLUGIN_NAME=$(echo "$PLUGIN" | jq -r '.name')
    PLUGIN_VERSION=$(echo "$PLUGIN" | jq -r '.version')
    PLUGIN_ENABLED=$(echo "$PLUGIN" | jq -r '.enabled')
    
    echo "Processing plugin: $PLUGIN_NAME ($PLUGIN_ID) v$PLUGIN_VERSION"
    
    # Check if plugin is enabled
    if [ "$PLUGIN_ENABLED" != "true" ]; then
        echo "  Skipping disabled plugin: $PLUGIN_NAME"
        continue
    fi
    
    # Extract owner and repo from plugin_id (format: owner.repo)
    PLUGIN_OWNER=$(echo "$PLUGIN_ID" | cut -d'.' -f1)
    PLUGIN_REPO=$(echo "$PLUGIN_ID" | cut -d'.' -f2)
    
    echo "  Owner: $PLUGIN_OWNER, Repo: $PLUGIN_REPO"
    
    # Check if plugin is already installed
    INSTALLED_PLUGINS=$(herdr plugin list --json 2>/dev/null || echo "[]")
    IS_INSTALLED=$(echo "$INSTALLED_PLUGINS" | jq --arg id "$PLUGIN_ID" 'any(.[]; .plugin_id == $id)')
    
    if [ "$IS_INSTALLED" = "true" ]; then
        echo "  Plugin already installed, updating..."
        herdr plugin update "$PLUGIN_OWNER/$PLUGIN_REPO"
    else
        echo "  Installing plugin..."
        herdr plugin install "$PLUGIN_OWNER/$PLUGIN_REPO"
    fi
    
    echo "  Done: $PLUGIN_NAME"
done

echo "All plugins processed."

# Enable all plugins defined in plugins.json
echo "Enabling all plugins..."
for ((i=0; i<PLUGIN_COUNT; i++)); do
    PLUGIN_ID=$(jq -r ".[$i].plugin_id" "$PLUGINS_JSON")
    herdr plugin enable "$PLUGIN_ID" 2>/dev/null || echo "  Could not enable $PLUGIN_ID (may not be installed)"
done

echo "Plugin installation/update complete."
