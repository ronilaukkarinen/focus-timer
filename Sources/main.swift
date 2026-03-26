import SwiftUI
import AppKit
import AVFoundation

struct FocusTimerApp {
    static let taskName: String = {
        let args = CommandLine.arguments
        if let idx = args.firstIndex(of: "--name"), idx + 1 < args.count {
            return args[idx + 1]
        }
        return "Focus"
    }()

    static let totalMinutes: Int = {
        let args = CommandLine.arguments
        if let idx = args.firstIndex(of: "--time"), idx + 1 < args.count {
            return Int(args[idx + 1]) ?? 25
        }
        return 25
    }()
}

class FlowTimerState: ObservableObject {
    @Published var elapsedSeconds: Int = 0
    @Published var isPaused = false
    @Published var isCompleted = false
    @Published var gradientPhase: Double = 0
    let estimatedSeconds: Int
    let taskName: String
    private var timer: Timer?
    private var gradientTimer: Timer?
    private var audioPlayer: AVAudioPlayer?
    private var halfwayBellPlayed = false
    private var completeBellPlayed = false

    init(minutes: Int, taskName: String) {
        self.estimatedSeconds = minutes * 60
        self.taskName = taskName
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            self.elapsedSeconds += 1

            if !self.halfwayBellPlayed && self.elapsedSeconds == self.estimatedSeconds / 2 {
                self.halfwayBellPlayed = true
                self.playBell()
            }

            if !self.completeBellPlayed && self.elapsedSeconds == self.estimatedSeconds {
                self.completeBellPlayed = true
                self.isCompleted = true
                self.playBell()
            }
        }

        gradientTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.gradientPhase += 0.003
        }
    }

    func togglePause() {
        isPaused.toggle()
        if isPaused {
            audioPlayer?.stop()
            audioPlayer = nil
        }
    }

    func complete() {
        timer?.invalidate()
        gradientTimer?.invalidate()
        NSApplication.shared.terminate(nil)
    }

    var progress: Double {
        guard estimatedSeconds > 0 else { return 0 }
        return min(Double(elapsedSeconds) / Double(estimatedSeconds), 1.0)
    }

    var actualProgress: Double {
        guard estimatedSeconds > 0 else { return 0 }
        return Double(elapsedSeconds) / Double(estimatedSeconds)
    }

    var isOvertime: Bool { elapsedSeconds > estimatedSeconds }

    var elapsedString: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    var estimatedString: String {
        let h = estimatedSeconds / 3600
        let m = (estimatedSeconds % 3600) / 60
        if h > 0 {
            return m > 0 ? "\(h)h \(m)min" : "\(h)h"
        }
        return "\(m)min"
    }

    var percentageString: String {
        return "\(Int(actualProgress * 100))%"
    }

    func playBell() {
        let paths = [
            Bundle.main.resourcePath.map { "\($0)/bell.aiff" },
            ProcessInfo.processInfo.arguments.first.map {
                URL(fileURLWithPath: $0).deletingLastPathComponent().appendingPathComponent("bell.aiff").path
            },
            "/opt/homebrew/share/focus-timer/bell.aiff",
            NSHomeDirectory() + "/Projects/focus-timer/Sources/bell.aiff"
        ].compactMap { $0 }

        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                guard let url = URL(string: "file://\(path)") else { continue }
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.play()
                    return
                } catch { continue }
            }
        }
        NSSound.beep()
    }
}

struct LivingGradient: View {
    let phase: Double
    let isOvertime: Bool
    let isPaused: Bool
    let pastHalfway: Bool

    var body: some View {
        let colors: [Color] = {
            if isPaused {
                return [
                    Color(red: 0.20, green: 0.20, blue: 0.25),
                    Color(red: 0.28, green: 0.28, blue: 0.32),
                    Color(red: 0.22, green: 0.22, blue: 0.26),
                    Color(red: 0.18, green: 0.18, blue: 0.22),
                ]
            }
            if isOvertime {
                return [
                    Color(red: 0.50, green: 0.06, blue: 0.10),
                    Color(red: 0.65, green: 0.08, blue: 0.12),
                    Color(red: 0.45, green: 0.05, blue: 0.08),
                    Color(red: 0.55, green: 0.10, blue: 0.15),
                ]
            }
            if pastHalfway {
                return [
                    Color(red: 0.50, green: 0.28, blue: 0.05),
                    Color(red: 0.60, green: 0.35, blue: 0.08),
                    Color(red: 0.45, green: 0.25, blue: 0.04),
                    Color(red: 0.55, green: 0.30, blue: 0.06),
                ]
            }
            return [
                Color(red: 0.25, green: 0.08, blue: 0.48),
                Color(red: 0.40, green: 0.12, blue: 0.60),
                Color(red: 0.28, green: 0.10, blue: 0.52),
                Color(red: 0.18, green: 0.06, blue: 0.38),
            ]
        }()

        let startX = 0.5 + 0.5 * cos(phase)
        let startY = 0.5 + 0.5 * sin(phase * 0.6)
        let endX = 0.5 + 0.5 * cos(phase + .pi)
        let endY = 0.5 + 0.5 * sin(phase * 0.6 + .pi)

        ZStack {
            // Base gradient
            LinearGradient(
                colors: colors,
                startPoint: UnitPoint(x: startX, y: startY),
                endPoint: UnitPoint(x: endX, y: endY)
            )

            // Blurred overlay blobs for smoother living effect
            Circle()
                .fill(colors[1].opacity(0.5))
                .frame(width: 280, height: 280)
                .blur(radius: 90)
                .offset(
                    x: 80 * cos(phase * 0.8),
                    y: 30 * sin(phase * 1.1)
                )

            Circle()
                .fill(colors[2].opacity(0.4))
                .frame(width: 240, height: 240)
                .blur(radius: 80)
                .offset(
                    x: -60 * cos(phase * 0.6 + 1),
                    y: -20 * sin(phase * 0.9 + 0.5)
                )

            Circle()
                .fill(colors[0].opacity(0.3))
                .frame(width: 200, height: 200)
                .blur(radius: 70)
                .offset(
                    x: 40 * sin(phase * 0.5 + 2),
                    y: 25 * cos(phase * 0.7 + 1)
                )
        }
        .animation(.easeInOut(duration: 0.8), value: isOvertime)
        .animation(.easeInOut(duration: 0.8), value: pastHalfway)
        .animation(.easeInOut(duration: 0.5), value: isPaused)
    }
}

struct FlowTimerView: View {
    @ObservedObject var state: FlowTimerState

    var progressBarColor: Color {
        if state.isPaused { return Color.white.opacity(0.25) }
        if state.isOvertime { return Color(red: 1.0, green: 0.35, blue: 0.35) }
        if state.actualProgress > 0.8 { return Color(red: 1.0, green: 0.7, blue: 0.3) }
        return Color.white.opacity(0.85)
    }

    var textColor: Color {
        if state.isPaused { return .white.opacity(0.4) }
        if state.isOvertime { return Color(red: 1.0, green: 0.4, blue: 0.4) }
        return .white
    }

    var dimTextColor: Color {
        if state.isPaused { return .white.opacity(0.2) }
        if state.isOvertime { return Color(red: 1.0, green: 0.4, blue: 0.4).opacity(0.7) }
        return .white.opacity(0.4)
    }

    var body: some View {
        ZStack {
            LivingGradient(
                phase: state.gradientPhase,
                isOvertime: state.isOvertime,
                isPaused: state.isPaused,
                pastHalfway: state.actualProgress >= 0.5 && !state.isOvertime
            )

            HStack(spacing: 0) {
                // Left: task info + time
                VStack(alignment: .leading, spacing: 6) {
                    // Task name + status
                    HStack {
                        Text(state.taskName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(textColor.opacity(0.9))
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Spacer()

                        if state.isPaused {
                            Text("PAUSED")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                        } else if state.isOvertime {
                            Text("OVERTIME")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.45))
                        }
                    }

                    // Time + percentage + goal on same line
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(state.elapsedString)
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(textColor)

                        Spacer()

                        HStack(spacing: 4) {
                            Text(state.percentageString)
                            Text("\u{00B7}")
                                .foregroundColor(.white.opacity(0.25))
                            Text(state.estimatedString)
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(dimTextColor)
                        .monospacedDigit()
                        .fixedSize()
                    }

                    // Full width progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2.5)
                                .fill(Color.white.opacity(0.1))
                            RoundedRectangle(cornerRadius: 2.5)
                                .fill(progressBarColor)
                                .frame(width: geo.size.width * state.progress)
                                .animation(.linear(duration: 1), value: state.progress)
                        }
                    }
                    .frame(height: 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Right: controls
                VStack(spacing: 12) {
                    Button(action: { state.togglePause() }) {
                        Image(systemName: state.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 13))
                            .foregroundColor(textColor.opacity(0.8))
                            .frame(width: 34, height: 34)
                            .background(textColor.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.space, modifiers: [])

                    Button(action: { state.complete() }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(textColor.opacity(0.8))
                            .frame(width: 34, height: 34)
                            .background(textColor.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.return, modifiers: [])
                }
                .padding(.leading, 16)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
        }
        .frame(width: 380, height: 130)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let timerState = FlowTimerState(
        minutes: FocusTimerApp.totalMinutes,
        taskName: FocusTimerApp.taskName
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        let view = FlowTimerView(state: timerState)
        let hostingView = NSHostingView(rootView: view)

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 130),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.contentView = hostingView
        window.level = .floating
        window.isReleasedWhenClosed = false
        window.isMovableByWindowBackground = true

        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.midX - window.frame.width / 2
            let y = screenFrame.midY - window.frame.height / 2
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        timerState.start()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
