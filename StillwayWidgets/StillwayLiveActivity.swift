import ActivityKit
import WidgetKit
import SwiftUI

struct StillwayLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StillwayActivityAttributes.self) { context in
            LiveActivityBanner(context: context)
                .activityBackgroundTint(.black.opacity(0.55))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        IslandOrb(isPlaying: context.state.isPlaying, hex: context.state.accentColorHex)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.soundName)
                                .font(.system(size: 14, weight: .semibold))
                                .lineLimit(1)
                            Text(context.state.contextName.uppercased())
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .tracking(1.2)
                                .foregroundStyle(Color(hexString: context.state.accentColorHex).opacity(0.85))
                        }
                    }
                    .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(Self.clock(context.state.remainingSeconds))
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white)
                        .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.center) {
                    MiniWaveStrip(
                        isPlaying: context.state.isPlaying,
                        hex: context.state.accentColorHex
                    )
                    .frame(height: 18)
                    .padding(.horizontal, 12)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 10) {
                        Image(systemName: atmosphereSymbol(context.state.atmosphereKind))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color(hexString: context.state.accentColorHex))
                        Text(context.state.atmosphereKind.uppercased())
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .tracking(1.1)
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        ProgressView(value: progress(context.state))
                            .tint(Color(hexString: context.state.accentColorHex))
                            .frame(width: 88)
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 6)
                }
            } compactLeading: {
                IslandOrb(isPlaying: context.state.isPlaying, hex: context.state.accentColorHex)
                    .frame(width: 20, height: 20)
            } compactTrailing: {
                Text(Self.clock(context.state.remainingSeconds))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color(hexString: context.state.accentColorHex))
            } minimal: {
                IslandOrb(isPlaying: context.state.isPlaying, hex: context.state.accentColorHex)
            }
            .keylineTint(Color(hexString: context.state.accentColorHex))
        }
    }

    private static func clock(_ seconds: Int) -> String {
        String(format: "%d:%02d", max(0, seconds) / 60, max(0, seconds) % 60)
    }

    private func progress(_ state: StillwayActivityAttributes.ContentState) -> Double {
        let minutes = max(1.0, Double(state.remainingSeconds) / 60.0)
        return min(1, max(0.08, 1.0 - (minutes / 60.0)))
    }

    private func atmosphereSymbol(_ kind: String) -> String {
        switch kind {
        case "aurora": return "sparkles"
        case "rain": return "cloud.rain.fill"
        case "lava": return "flame.fill"
        case "stream": return "water.waves"
        case "ember": return "sun.haze.fill"
        default: return "aqi.medium"
        }
    }
}

// MARK: - Banner

private struct LiveActivityBanner: View {
    let context: ActivityViewContext<StillwayActivityAttributes>

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hexString: context.state.accentColorHex).opacity(0.35),
                    Color.black.opacity(0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            HStack(spacing: 14) {
                IslandOrb(isPlaying: context.state.isPlaying, hex: context.state.accentColorHex)
                    .frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 3) {
                    Text(context.state.soundName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                    HStack(spacing: 6) {
                        Text(context.state.contextName.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(1.2)
                        Text("·")
                            .opacity(0.4)
                        Text(context.state.atmosphereKind.uppercased())
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .tracking(0.8)
                            .opacity(0.7)
                    }
                    .foregroundStyle(Color(hexString: context.state.accentColorHex))
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 6) {
                    Text(clockLabel(context.state.remainingSeconds))
                        .font(.system(size: 22, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white)
                    MiniWaveStrip(isPlaying: context.state.isPlaying, hex: context.state.accentColorHex)
                        .frame(width: 54, height: 14)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
    }

    private func clockLabel(_ seconds: Int) -> String {
        String(format: "%d:%02d", max(0, seconds) / 60, max(0, seconds) % 60)
    }
}

// MARK: - Shared ornaments

private struct IslandOrb: View {
    let isPlaying: Bool
    let hex: String

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hexString: hex).opacity(0.35))
                .blur(radius: 4)
                .scaleEffect(isPlaying ? 1.25 : 1.0)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hexString: hex), Color(hexString: hex).opacity(0.2)],
                        center: .center,
                        startRadius: 1,
                        endRadius: 14
                    )
                )
            Image(systemName: isPlaying ? "waveform" : "moon.zzz.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .symbolEffect(.variableColor.iterative, isActive: isPlaying)
        }
        .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: isPlaying)
    }
}

private struct MiniWaveStrip: View {
    let isPlaying: Bool
    let hex: String

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 12.0, paused: !isPlaying)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            HStack(alignment: .center, spacing: 2) {
                ForEach(0..<7, id: \.self) { i in
                    let h = isPlaying
                        ? 4 + abs(sin(t * 2.2 + Double(i) * 0.7)) * 10
                        : 4.0
                    Capsule()
                        .fill(Color(hexString: hex).opacity(0.85))
                        .frame(width: 3, height: h)
                }
            }
        }
    }
}
