<h1 align="center">Focus Timer</h1>

<p align="center">
  <strong>A beautiful floating flow timer for deep work sessions, designed for Claude Code integration</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift" />
  <img src="https://img.shields.io/badge/SwiftUI-007AFF?style=for-the-badge&logo=swift&logoColor=white" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/Claude_Code-cc785c?style=for-the-badge&logo=anthropic&logoColor=white" alt="Claude Code" />
</p>

---

## What is Focus Timer?

A native macOS floating widget that counts **up** (not down) to help you stay in flow. Launched from the command line - designed to be triggered by Claude Code during daily planning sessions.

Unlike a pomodoro timer that interrupts your flow, Focus Timer lets you keep going past the estimated time. It gently signals milestones (halfway bell, completion bell) and visually shifts through color states so you always know where you are without breaking focus.

## Features

### Flow-based timing

Counts up from zero toward an estimated duration. No hard stops - the timer keeps running into overtime so you can finish your thought. A tibetan singing bowl bell rings at the halfway point and when estimated time is reached.

### Living gradient background

The background is a slowly breathing purple gradient that shifts through states:
- **Purple** - normal focus time
- **Orange** - past the halfway point, gentle reminder
- **Red** - overtime, you've exceeded the estimate
- **Gray** - paused

### Floating always-on-top widget

Borderless, rounded, draggable window that floats above all other windows. Stays visible while you code without being intrusive. Position it wherever you want.

### Claude Code integration

Designed to be launched by Claude Code's daily planner:

```bash
focus-timer --name "Deep work: KM-108 TTS" --time 45
```

The planner can trigger it automatically when scheduling deep work blocks.

## Install

### Build from source

Requires Swift 5.9+ and macOS 13+.

```bash
git clone https://github.com/ronilaukkarinen/focus-timer.git
cd focus-timer
swift build -c release
cp .build/release/focus-timer /opt/homebrew/bin/focus-timer
```

### Homebrew (planned)

Not yet available.

## Usage

```bash
# 45-minute deep work session
focus-timer --name "Deep work: KM-108 TTS" --time 45

# Quick 15-minute task
focus-timer --name "Code review" --time 15

# Default 25 minutes
focus-timer --name "Focus"
```

### Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `--name` | `Focus` | Task name displayed in the widget |
| `--time` | `25` | Estimated duration in minutes |

### Keyboard shortcuts

| Key | Action |
|-----|--------|
| Space | Pause / Resume |
| Enter | Complete and close |

### Color states

| State | Background | Trigger |
|-------|------------|---------|
| Normal | Purple gradient | 0-49% of estimated time |
| Halfway | Orange gradient | 50-99% + bell |
| Overtime | Red gradient | 100%+ bell |
| Paused | Gray gradient | Space key |

## Claude Code integration

Add this to your planner command (e.g. `plan-today.md`) so Claude launches the timer for deep work blocks:

```
When scheduling deep work blocks in the Day Planner section, launch the focus timer
in the background using: focus-timer --name "Task name" --time <minutes> &
```

## How it works

Focus Timer is a single-file SwiftUI application (~300 lines). No Electron, no web views, no runtime dependencies.

- **NSWindow** with `.borderless` style and `.floating` level
- **SwiftUI** for the UI with animated gradient background
- **AVFoundation** for playing the tibetan singing bowl bell
- **Timer** ticking every second, gradient animating at 30fps

The bell sound is a tibetan singing bowl converted from the [focus](https://github.com/ayoisaiah/focus) CLI tool.

## Requirements

- macOS 13 (Ventura) or later
- Swift 5.9+ (for building from source)

## Credits

- Bell sound from [focus](https://github.com/ayoisaiah/focus) by Ayooluwa Isaiah
- Inspired by the flow timer concept in focus and [Sunsama](https://sunsama.com)
