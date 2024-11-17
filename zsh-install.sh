#!/bin/bash

set -e

# Check if Zsh is installed, if not, install it
if ! command -v zsh &> /dev/null; then
    echo "Installing Zsh..."
    sudo apt update && sudo apt install -y zsh
fi

# Change the default shell to Zsh
if [[ "$SHELL" != "$(which zsh)" ]]; then
    echo "Changing default shell to Zsh..."
    chsh -s "$(which zsh)"
fi

# Install Oh My Zsh if not already installed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install zsh-autosuggestions plugin
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
fi

# Install zsh-syntax-highlighting plugin
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
fi

# Install kubectl completion
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Please install kubectl first."
    exit 1
fi

echo "Enabling kubectl autocompletion..."
mkdir -p ~/.zsh/completion
kubectl completion zsh > ~/.zsh/completion/_kubectl

# Add kubectl autocompletion and plugins to .zshrc
ZSHRC="$HOME/.zshrc"

if ! grep -q "kubectl completion zsh" "$ZSHRC"; then
    echo "Adding kubectl autocompletion to .zshrc..."
    cat << 'EOF' >> "$ZSHRC"

# Enable kubectl autocompletion
source ~/.zsh/completion/_kubectl

# Enable Oh My Zsh plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Load Oh My Zsh plugins
for plugin in $plugins; do
    source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin/$plugin.zsh
done
EOF
fi

# Install Powerlevel10k theme (optional)
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
    echo "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"
fi

echo "Installation complete! Please restart your terminal or run 'exec zsh' to apply the changes."
