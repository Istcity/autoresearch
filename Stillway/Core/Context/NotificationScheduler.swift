import Foundation
import UserNotifications
import UIKit

enum StillwayNotificationCategory: String {
    case commute = "stillway.commute"
    case sleep = "stillway.sleep"
    case focus = "stillway.focus"
    case placeLabel = "stillway.place_label"
}

enum StillwayNotificationAction: String {
    case start = "stillway.start"
    case dismiss = "stillway.dismiss"
    case label = "stillway.label"
}

/// Schedules and handles local notifications for commute / sleep / focus / place labeling.
@MainActor
final class NotificationScheduler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationScheduler()

    var onStartSuggested: ((AppContext) -> Void)?
    var onOpenPlaceLabel: (() -> Void)?

    private var lastFire: [String: Date] = [:]
    private let cooldown: TimeInterval = 30 * 60

    private override init() {
        super.init()
    }

    func configure() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let start = UNNotificationAction(
            identifier: StillwayNotificationAction.start.rawValue,
            title: NSLocalizedString("notif_action_start", comment: ""),
            options: [.foreground]
        )
        let dismiss = UNNotificationAction(
            identifier: StillwayNotificationAction.dismiss.rawValue,
            title: NSLocalizedString("notif_action_dismiss", comment: ""),
            options: []
        )
        let label = UNNotificationAction(
            identifier: StillwayNotificationAction.label.rawValue,
            title: NSLocalizedString("notif_action_label", comment: ""),
            options: [.foreground]
        )
        let categories: Set<UNNotificationCategory> = [
            UNNotificationCategory(identifier: StillwayNotificationCategory.commute.rawValue, actions: [start, dismiss], intentIdentifiers: []),
            UNNotificationCategory(identifier: StillwayNotificationCategory.sleep.rawValue, actions: [start, dismiss], intentIdentifiers: []),
            UNNotificationCategory(identifier: StillwayNotificationCategory.focus.rawValue, actions: [start, dismiss], intentIdentifiers: []),
            UNNotificationCategory(identifier: StillwayNotificationCategory.placeLabel.rawValue, actions: [label, dismiss], intentIdentifiers: [])
        ]
        center.setNotificationCategories(categories)
    }

    func suggestCommute(body: String) {
        schedule(
            id: "commute",
            title: "Stillway",
            body: body,
            category: .commute,
            userInfo: ["context": AppContext.commute.rawValue]
        )
    }

    func suggestSleep(body: String) {
        schedule(
            id: "sleep",
            title: "Stillway",
            body: body,
            category: .sleep,
            userInfo: ["context": AppContext.sleep.rawValue]
        )
    }

    func suggestFocus(body: String) {
        schedule(
            id: "focus",
            title: "Stillway",
            body: body,
            category: .focus,
            userInfo: ["context": AppContext.focus.rawValue]
        )
    }

    func suggestPlaceLabel(body: String) {
        schedule(
            id: "place_label",
            title: "Stillway",
            body: body,
            category: .placeLabel,
            userInfo: ["action": "place_label"],
            cooldownOverride: 12 * 60 * 60
        )
    }

    private func schedule(
        id: String,
        title: String,
        body: String,
        category: StillwayNotificationCategory,
        userInfo: [AnyHashable: Any],
        cooldownOverride: TimeInterval? = nil
    ) {
        let gate = cooldownOverride ?? cooldown
        if let previous = lastFire[id], Date().timeIntervalSince(previous) < gate {
            return
        }
        lastFire[id] = Date()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = category.rawValue
        content.userInfo = userInfo

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "stillway.\(id).\(Int(Date().timeIntervalSince1970))",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - UNUserNotificationCenterDelegate

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let info = response.notification.request.content.userInfo
        let action = response.actionIdentifier
        Task { @MainActor in
            if action == StillwayNotificationAction.label.rawValue
                || (info["action"] as? String == "place_label"
                    && (action == UNNotificationDefaultActionIdentifier || action == StillwayNotificationAction.label.rawValue)) {
                self.onOpenPlaceLabel?()
            } else if action == StillwayNotificationAction.start.rawValue
                        || action == UNNotificationDefaultActionIdentifier {
                if let raw = info["context"] as? Int, let context = AppContext(rawValue: raw) {
                    self.onStartSuggested?(context)
                }
            }
        }
        completionHandler()
    }
}
