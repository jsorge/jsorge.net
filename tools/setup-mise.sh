#!/usr/bin/env bash

set -e
set -o pipefail

echo "Installing mise..."
curl https://mise.run | sh

# Add mise to PATH for current session
export PATH="$HOME/.local/bin:$PATH"

# Detect shell and add mise activation to profile
SHELL_NAME=$(basename "$SHELL")
case "$SHELL_NAME" in
    bash)
        PROFILE="$HOME/.bashrc"
        ACTIVATION='eval "$(~/.local/bin/mise activate bash)"'
        ;;
    zsh)
        PROFILE="$HOME/.zshrc"
        ACTIVATION='eval "$(~/.local/bin/mise activate zsh)"'
        ;;
    fish)
        PROFILE="$HOME/.config/fish/config.fish"
        ACTIVATION='~/.local/bin/mise activate fish | source'
        ;;
    *)
        echo "Unknown shell: $SHELL_NAME"
        echo "Add mise activation to your shell profile manually."
        echo "See: https://mise.jdx.dev/getting-started.html"
        exit 0
        ;;
esac

# Add activation to profile if not already present
if ! grep -q "mise activate" "$PROFILE" 2>/dev/null; then
    echo "" >> "$PROFILE"
    echo "# mise" >> "$PROFILE"
    echo "$ACTIVATION" >> "$PROFILE"
    echo "Added mise activation to $PROFILE"
else
    echo "mise activation already in $PROFILE"
fi

echo ""
echo "mise installed successfully!"
echo "Run 'source $PROFILE' or start a new shell to use mise."
