import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class ThemeEngine {
    var currentContext: AppContext = .unknown
    var displayedContext: AppContext = .unknown
    var waveAmplitudeScale: Double = 1
    var isTransitioning = false
    var transitionProgress: Double = 1

    var gradient: ContextGradient { ContextGradient.for(displayedContext) }
    var waveConfig: WaveConfig { WaveConfig.for(displayedContext) }
    var targetGradient: ContextGradient { ContextGradient.for(currentContext) }

    func apply(_ context: AppContext) {
        guard context != currentContext else { return }
        Task { await transition(to: context) }
    }

    func transition(to context: AppContext) async {
        guard context != currentContext else { return }
        isTransitioning = true
        currentContext = context

        withAnimation(.easeIn(duration: 0.4)) {
            waveAmplitudeScale = 0
        }
        try? await Task.sleep(for: .milliseconds(400))

        withAnimation(.easeInOut(duration: 0.6)) {
            displayedContext = context
            transitionProgress = 0
        }
        try? await Task.sleep(for: .milliseconds(600))

        withAnimation(.spring(response: 0.8, dampingFraction: 0.82)) {
            waveAmplitudeScale = 1
            transitionProgress = 1
        }
        try? await Task.sleep(for: .milliseconds(800))
        isTransitioning = false
    }
}
