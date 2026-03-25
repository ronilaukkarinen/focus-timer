<h1 align="center">🎯 Focus Timer</h1>

<p align="center">
  <strong>A beautiful floating flow timer for deep work sessions</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/SwiftUI-007AFF?style=for-the-badge&logo=swift&logoColor=white" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="macOS" />
  <img src="https://img.shields.io/badge/Claude_Code-cc785c?style=for-the-badge&logo=anthropic&logoColor=white" alt="Claude Code" />
</p>

---

<img width="878" height="291" alt="image" src="https://github.com/user-attachments/assets/fe575a52-f226-4257-9689-c7b80f595c1e" />

## What is Focus Timer?

A native macOS floating widget that counts **up** toward an estimated duration. No hard stops - the timer keeps running into overtime. A tibetan singing bowl rings at the halfway point and when estimated time is reached. The living gradient background shifts from purple to orange (halfway) to red (overtime) to gray (paused).

## Install

```bash
git clone https://github.com/ronilaukkarinen/focus-timer.git
cd focus-timer
swift build -c release
cp .build/release/focus-timer /opt/homebrew/bin/focus-timer
```

## Usage

```bash
focus-timer --name "Deep work: KM-108 TTS" --time 45
```

| Argument | Default | Description |
|----------|---------|-------------|
| `--name` | `Focus` | Task name displayed in the widget |
| `--time` | `25` | Estimated duration in minutes |

| Key | Action |
|-----|--------|
| Space | Pause / Resume |
| Enter | Complete and close |

| State | Background | Trigger |
|-------|------------|---------|
| Normal | Purple | 0-49% |
| Halfway | Orange | 50-99% + bell |
| Overtime | Red | 100%+ bell |
| Paused | Gray | Space key |

## Claude Code integration

Designed to be launched by Claude Code during daily planning. Add to your planner command:

```
When scheduling deep work blocks, launch the focus timer in the background:
focus-timer --name "Task name" --time <minutes> &
```

## Requirements

- macOS 13 or later
