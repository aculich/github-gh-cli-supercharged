#!/bin/bash
# Test script to verify that sourcing is completely silent

echo "Testing gh-config.zsh silence..."
OUTPUT=$(zsh -c "source gh-config.zsh 2>&1" 2>&1)
LINES=$(echo "$OUTPUT" | wc -l | tr -d ' ')
if [ "$LINES" -eq 0 ] || [ -z "$OUTPUT" ]; then
    echo "✓ gh-config.zsh is silent (0 lines of output)"
else
    echo "✗ gh-config.zsh outputs $LINES lines:"
    echo "$OUTPUT" | head -10
fi

echo ""
echo "Testing plugin file silence..."
if [ -f "oh-my-zsh-plugin/github-gh-cli-supercharged.plugin.zsh" ]; then
    OUTPUT=$(zsh -c "source oh-my-zsh-plugin/github-gh-cli-supercharged.plugin.zsh 2>&1" 2>&1)
    LINES=$(echo "$OUTPUT" | wc -l | tr -d ' ')
    if [ "$LINES" -eq 0 ] || [ -z "$OUTPUT" ]; then
        echo "✓ Plugin file is silent (0 lines of output)"
    else
        echo "✗ Plugin file outputs $LINES lines:"
        echo "$OUTPUT" | head -10
    fi
else
    echo "⚠ Plugin file not found"
fi

echo ""
echo "Testing installed plugin (if exists)..."
if [ -f ~/.oh-my-zsh/custom/plugins/github-gh-cli-supercharged/github-gh-cli-supercharged.plugin.zsh ]; then
    OUTPUT=$(zsh -c "source ~/.oh-my-zsh/custom/plugins/github-gh-cli-supercharged/github-gh-cli-supercharged.plugin.zsh 2>&1" 2>&1)
    LINES=$(echo "$OUTPUT" | wc -l | tr -d ' ')
    if [ "$LINES" -eq 0 ] || [ -z "$OUTPUT" ]; then
        echo "✓ Installed plugin is silent (0 lines of output)"
    else
        echo "✗ Installed plugin outputs $LINES lines:"
        echo "$OUTPUT" | head -10
        echo ""
        echo "💡 Try updating the plugin:"
        echo "   cd ~/.oh-my-zsh/custom/plugins/github-gh-cli-supercharged"
        echo "   git pull origin main"
    fi
else
    echo "⚠ Installed plugin not found"
fi
