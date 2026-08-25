import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class ThemeEngine {
    var currentContext: AppContext = .unknown
    var isTransitioning = false
    var transitionAmplitude: Double = 1

    var displayedContext: AppContext { currentContext }
    var gradient: ContextGradient { ContextGradient.gradient(for: currentContext) }
    var waveConfig: WaveConfig { WaveConfig.config(for: currentContext) }
    var effectiveAmplitude: Double { waveConfig.amplitude * transitionAmplitude }
    var waveAmplitudeScale: Double { transitionAmplitude }

    func apply(context: AppContext) {
        guard context != currentContext else { return }
        Task { await transition(to: context) }
    }

    func apply(_ context: AppContext) {
        apply(context: context)
    }

    func transition(to context: AppContext) async {
        guard context != currentContext else { return }
        isTransitioning = true
        withAnimation(.easeIn(duration: 0.4)) {
            transitionAmplitude = 0
        }
        try? await Task.sleep(for: .milliseconds(400))
        currentContext = context
        withAnimation(.spring(response: 0.8, dampingFraction: 0.82)) {
            transitionAmplitude = 1
        }
        try? await Task.sleep(for: .milliseconds(800))
        isTransitioning = false
    }
}
