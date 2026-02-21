import Foundation
import UserNotifications

final class NotificationService: Sendable {
    static let shared = NotificationService()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound]
        ) { _, error in
            if let error { print("Notification permission error: \(error)") }
        }
    }

    func notifyPipelineChange(mrTitle: String, newStatus: PipelineStatus) {
        let content = UNMutableNotificationContent()
        content.title = "Pipeline \(newStatus.displayName)"
        content.body = mrTitle
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    func notifyApprovalChange(mrTitle: String, approvedBy: String) {
        let content = UNMutableNotificationContent()
        content.title = "MR Approved"
        content.body = "\(approvedBy) approved: \(mrTitle)"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
