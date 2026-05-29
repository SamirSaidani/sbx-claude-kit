#!/bin/sh
# Inject Claude config files after sbx init
mkdir -p /home/agent/.claude

# Copy files to .claude/
cp /home/agent/.sbx/statusline-command.sh /home/agent/.claude/statusline-command.sh
chmod +x /home/agent/.claude/statusline-command.sh

# Write full settings.json (customize to your needs)
cat > /home/agent/.claude/settings.json << 'EOF'
{
  "alwaysThinkingEnabled": true,
  "skipDangerousModePermissionPrompt": true,
  "themeId": 1,
  "defaultMode": "bypassPermissions",
  "bypassPermissionsModeAccepted": true,
  "model": "haiku",
  "effortLevel": "medium",
  "voiceEnabled": true,
  "autoCompactEnabled": false,
  "env": {
    "CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY": "1",
    "DISABLE_AUTOUPDATER": "1"
  },
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "paplay /usr/share/sounds/freedesktop/stereo/complete.oga"
          }
        ]
      }
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
  }
}
EOF
