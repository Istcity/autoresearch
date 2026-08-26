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
        withAnimation(.easeInOut(duration: 1.1)) {
            transitionAmplitude = 0.15
        }
        try? await Task.sleep(for: .milliseconds(1100))
        currentContext = context
        withAnimation(.easeInOut(duration: 1.6)) {
            transitionAmplitude = 1
        }
        try? await Task.sleep(for: .milliseconds(1600))
        isTransitioning = false
    }
}
