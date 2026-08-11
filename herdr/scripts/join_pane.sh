#!/usr/bin/env bash

# Herdr join_pane equivalent script
# Joins first pane from another tab into current tab with horizontal split (right)
# Result: [existing_pane][joined_pane] in current tab

# Get list of all panes in workspace
PANES_JSON=$(herdr pane list --workspace $HERDR_WORKSPACE_ID)

# Find first pane that belongs to a different tab than current tab
let i=0
while true; do
	TAB_ID=$(echo "$PANES_JSON" | jq -r ".result.panes[$i].tab_id")
	PANE_ID=$(echo "$PANES_JSON" | jq -r ".result.panes[$i].pane_id")

	# Check if we've reached the end of panes
	if [ "$TAB_ID" = "null" ] || [ "$PANE_ID" = "null" ]; then
		exit 1
	fi

	# Skip panes that belong to current tab
	if [ "$TAB_ID" != "$HERDR_TAB_ID" ]; then
		herdr notification show "$( herdr pane move "$PANE_ID" --tab "$HERDR_TAB_ID" --split right )"
		exit 0
	fi

	((i++))
done
