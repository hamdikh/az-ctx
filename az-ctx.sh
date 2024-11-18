#!/bin/bash

az_ctx() {
    # Ensure az CLI, jq, and fzf are installed
    if ! command -v az &> /dev/null || ! command -v jq &> /dev/null || ! command -v fzf &> /dev/null; then
        echo "Error: az, jq, and fzf are required for this script."
        echo "Please install them for your operating system."
        return 1
    fi

    # Fetch the subscription list with jq to ensure clean parsing
    local selected_subscription
    selected_subscription=$(az account list --query "[].{name:name, id:id}" -o json | \
    jq -r '.[] | "\(.id) \(.name)"' | \
    fzf --prompt="Select Azure Subscription: " --height=15 --layout=reverse --preview="echo {}")

    # Check if a subscription was selected
    if [ -z "$selected_subscription" ]; then
        echo "No subscription selected."
        return
    fi

    # Extract subscription ID and Name
    local subscription_id subscription_name
    subscription_id=$(echo "$selected_subscription" | awk '{print $1}')
    subscription_name=$(echo "$selected_subscription" | awk '{$1=""; print $0}' | sed 's/^ *//')

    # Set the subscription if ID is valid
    if [ -n "$subscription_id" ]; then
        az account set --subscription "$subscription_id" && \
        echo "Switched to subscription: $subscription_name"
    else
        echo "Error: Unable to extract a valid subscription ID."
    fi
}
