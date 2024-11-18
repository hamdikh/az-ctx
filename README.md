# Azure Subscription Switcher (`az_ctx`)

`az_ctx` is a simple Bash function that allows you to quickly switch between Azure subscriptions interactively using `fzf`, a powerful command-line fuzzy finder.

## Features

- **Interactive Subscription Selection:** Use `fzf` to choose from available Azure subscriptions.
- **Fast and Reliable:** Uses Azure CLI (`az`) and `jq` for robust parsing and execution.
- **Customizable:** Easy to extend or adapt to your needs.

## Prerequisites

- **Azure CLI (`az`)**: Ensure Azure CLI is installed and you are logged in:
  ```bash
  az login
  ```
- **fzf**: Install `fzf` using your package manager:
  ```bash
  sudo apt install fzf       # Ubuntu/Debian
  brew install fzf           # macOS
  ```
- **jq**: Install `jq` for JSON parsing:
  ```bash
  sudo apt install jq        # Ubuntu/Debian
  brew install jq            # macOS
  ```

## Installation

1. Add the `az_ctx` function to your shell configuration file (`~/.bashrc`, `~/.zshrc`, or equivalent):

   ```bash
   az_ctx() {
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

       # Debugging Output
       echo "Extracted Subscription ID: $subscription_id"
       echo "Extracted Subscription Name: $subscription_name"

       # Set the subscription if ID is valid
       if [ -n "$subscription_id" ]; then
           az account set --subscription "$subscription_id" && \
           echo "Switched to subscription: $subscription_name"
       else
           echo "Error: Unable to extract a valid subscription ID."
       fi
   }
   ```

2. Reload your shell configuration:
   ```bash
   source ~/.bashrc
   ```

## Usage

Run the `az_ctx` command in your terminal:
```bash
az_ctx
```

### Example Workflow

1. Run `az_ctx`:
   ```bash
   az_ctx
   ```
2. Select an Azure subscription from the `fzf` interactive menu.
3. Confirm the active subscription:
   ```bash
   az account show
   ```

## Debugging

If you encounter issues:
1. Verify `az account list` output:
   ```bash
   az account list --query "[].{name:name, id:id}" -o json
   ```
2. Test the `fzf` integration:
   ```bash
   az account list --query "[].{name:name, id:id}" -o json | jq -r '.[] | "\(.id) \(.name)"' | fzf
   ```

## License

This script is open-source and can be used or modified freely. Contributions are welcome!
