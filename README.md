# sbx-claude-kit

A [Docker sbx](https://docs.docker.com/ai/sandboxes/) mixin kit that solves two problems when running Claude Code in sandboxes:

1. **`~/.claude/settings.json` is overwritten** on every sandbox creation ([docker/sbx-releases#113](https://github.com/docker/sbx-releases/issues/113))
2. **Audio (notifications, voice mode) doesn't work** because sandboxes have no access to host audio devices ([docker/sbx-releases#66](https://github.com/docker/sbx-releases/issues/66))

## How it works

### Settings injection

sbx recreates agent config files (`~/.claude/`) on every sandbox creation, even from templates. This kit works around it by placing an `init.sh` script in `~/.sbx/` (untouched by sbx) and running it as a startup command — after sbx's own init — to overwrite `settings.json` with your desired configuration.

### PulseAudio via host.docker.internal

Since sbx 30, sandboxes can reach host services through `host.docker.internal`. The kit uses `allowedDomains` to permit TCP traffic to PulseAudio on the host, and sets `PULSE_SERVER` so all audio clients in the sandbox connect transparently.

```
sandbox (paplay) -> host.docker.internal:4713 -> host PulseAudio/PipeWire
```

This enables both playback and recording — notifications and **voice mode** work.

## Prerequisites

On the **host**, enable PulseAudio/PipeWire TCP:

```bash
pactl load-module module-native-protocol-tcp auth-anonymous=1
```

> To make this persistent, add `load-module module-native-protocol-tcp auth-anonymous=1` to `~/.config/pulse/default.pa` (PulseAudio) or configure it via PipeWire.

No `sbx policy` changes required — the kit's `allowedDomains` handles network access.

## Usage

### With the kit directory

```bash
sbx run claude --kit ./path/to/sbx-claude-kit/
```

### With a zip

```bash
zip -r sbx-claude-kit.zip spec.yaml files/
sbx run claude --kit sbx-claude-kit.zip
```

### On an existing sandbox

```bash
sbx kit add <sandbox-name> ./path/to/sbx-claude-kit/
```

## Kit structure

```
sbx-claude-kit/
├── spec.yaml                        # Kit manifest: network, env vars, install & startup commands
├── notify-server.py                 # (Optional) HTTP-based notification server for older sbx versions
└── files/
    └── home/
        └── .sbx/
            ├── init.sh              # Startup script: settings.json injection
            └── statusline-command.sh # Claude Code status line script
```

## What the kit installs

- `sox` + `libsox-fmt-pulse` — audio recording/playback with PulseAudio backend
- `pulseaudio-utils` — `paplay`, `parecord`
- `sound-theme-freedesktop` — standard notification sounds

## Customization

Edit `files/home/.sbx/init.sh` to change the `settings.json` content. The current defaults include:

- Bypass permissions mode
- Voice mode enabled
- Auto-compact disabled
- Notification hook (sound on task completion)
- Status line with model name and context window usage

## Notify server (alternative for sbx < 30)

If your sbx version doesn't support `host.docker.internal` for non-HTTP TCP, `notify-server.py` provides an HTTP-based alternative for notification sounds only. Run it on the host:

```bash
python3 notify-server.py
```

Then use `curl -s http://172.17.0.1:8888/` as the notification hook command.

For older sbx versions, you can also use a `socat` tunnel through the HTTP CONNECT proxy — see [this comment](https://github.com/docker/sbx-releases/issues/66) for details.

## Related issues

- [docker/sbx-releases#113](https://github.com/docker/sbx-releases/issues/113) — `~/.claude` config not persisted
- [docker/sbx-releases#66](https://github.com/docker/sbx-releases/issues/66) — Voice mode / audio not working in sandboxes
- [docker/sbx-releases#147](https://github.com/docker/sbx-releases/issues/147) — Non-HTTP TCP access to host services
