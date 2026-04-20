import Foundation
import UserNotifications

class NotificationService {
    
    static let shared = NotificationService()
    
    // MARK: - Request Permission
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                print("Notifications permission: \(granted)")
            }
    }
    
    // MARK: - Send Local Notification
    func sendNotification(title: String, body: String, delay: Double = 1.0) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: delay,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
    
    // MARK: - Order Notifications
    func notifyOrderPlaced(orderId: String) {
        sendNotification(
            title: "🛒 Order Placed!",
            body: "Your order #\(String(orderId.prefix(8)).uppercased()) has been placed successfully!"
        )
    }
    
    func notifyOrderConfirmed(orderId: String) {
        sendNotification(
            title: "✅ Order Confirmed!",
            body: "Your order #\(String(orderId.prefix(8)).uppercased()) has been confirmed and is being prepared!"
        )
    }
    
    func notifyOrderDelivered(orderId: String) {
        sendNotification(
            title: "🎉 Order Delivered!",
            body: "Your order #\(String(orderId.prefix(8)).uppercased()) has been delivered. Enjoy!"
        )
    }
}
