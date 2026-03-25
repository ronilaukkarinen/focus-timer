## Commits and code style

- Never use Claude watermark in commits (FORBIDDEN: "Co-Authored-By")
- No emojis in commits or code
- One logical change per commit
- Keep commit messages concise (one line), use sentence case
- Use present tense in commits
- Use sentence case for headings (not Title Case)
- Never use bold text as headings, use proper heading levels instead
- Always add an empty line after headings

## Swift/SwiftUI code style

- Use 4 spaces for indentation
- Keep the app as a single-file SwiftUI application (Sources/main.swift)
- Use system SF fonts, never monospaced for display text
- Use computed properties for dynamic colors that respond to timer state
- Prefer SwiftUI animations and property bindings over imperative updates
- Keep the window borderless and floating - no title bar, no chrome
- All colors must adapt dynamically to timer state (normal/halfway/overtime/paused)

## Claude Code workflow

- ALWAYS use Helsinki timezone (Europe/Helsinki) for all timestamps
- Always add tasks to the Claude Code to-do list and keep it up to date
- Do not ever guess features, always proof them via looking up official docs, GitHub code, issues, if possible
- NEVER just patch the line you see. Before fixing, trace the full chain
- Prefer DRY code - avoid repeating logic, extract shared patterns
- Test builds with `swift build -c release` before committing

## Project structure

- `Package.swift` - Swift package manifest
- `Sources/main.swift` - Entire application (SwiftUI + AppKit)
- `Sources/bell.aiff` - Tibetan singing bowl bell sound
- `README.md` - Documentation
