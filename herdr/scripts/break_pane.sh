#!/bin/bash

# Herdr break-pane -d equivalent script
# Moves the current pane to a new tab and returns to original tab

# Get the current pane and tab IDs
CURRENT_PANE=$(herdr pane current | jq -r ".result.pane.pane_id")
herdr pane move "$CURRENT_PANE" --new-tab --no-focus

