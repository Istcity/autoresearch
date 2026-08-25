import ActivityKit
import WidgetKit
import SwiftUI

struct StillwayLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StillwayActivityAttributes.self) { context in
            HStack {
                Image(systemName: "waveform")
                    .foregroundStyle(Color(hexString: context.state.accentColorHex))
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.state.soundName)
                        .font(.system(size: 15, weight: .semibold))
                    Text(context.state.contextName.uppercased())
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .tracking(1)
                        .opacity(0.7)
                }
                Spacer()
                Text(Self.clock(context.state.remainingSeconds))
                    .font(.system(size: 22, weight: .medium, design: .monospaced))
            }
            .padding(.horizontal, 16)
            .activityBackgroundTint(Color.black.opacity(0.35))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "waveform")
                        .symbolEffect(.variableColor, isActive: context.state.isPlaying)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(Self.clock(context.state.remainingSeconds))
                        .font(.system(size: 17, weight: .medium, design: .monospaced))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.soundName)
                        Spacer()
                        Text(context.state.contextName.uppercased())
                            .tracking(1.2)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                    }
                    .font(.system(size: 13))
                }
            } compactLeading: {
                Image(systemName: "waveform")
            } compactTrailing: {
                Text(Self.clock(context.state.remainingSeconds))
                    .font(.system(size: 12, design: .monospaced))
            } minimal: {
                Image(systemName: "waveform")
                    .symbolEffect(.pulse, isActive: context.state.isPlaying)
            }
        }
    }

    private static func clock(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
