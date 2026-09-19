import WidgetKit
import SwiftUI
import AppIntents

struct LockScreenWidget: Widget {
    let kind = "StillwayLockScreen"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StillwayTimelineProvider()) { entry in
            LockScreenWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Stillway")
        .description("Start or stop Stillway with a single tap.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct LockScreenWidgetView: View {
    var entry: StillwayEntry

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: entry.isPlaying ? "waveform" : "play.fill")
                .font(.system(size: 20, weight: .medium))
                .symbolEffect(.variableColor, isActive: entry.isPlaying)
            Text(entry.isPlaying ? entry.remainingLabel : "Stillway")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
        }
        .widgetURL(URL(string: "stillway://toggle"))
    }
}
