//
//  UserNotificationClient.swift
//  Pochi
//
//  Created by Pochi Team on 2025/06/21.
//

import Dependencies
import Foundation
@preconcurrency import UserNotifications

// MARK: - User Notification Client

struct UserNotificationClient: Sendable {
  var requestAuthorization: @Sendable () async -> Bool
  var getAuthorizationStatus: @Sendable () async -> UNAuthorizationStatus
  var scheduleExpiryNotification: @Sendable (Item, Int) async throws -> Void
  var cancelNotification: @Sendable (String) async -> Void
  var cancelAllNotifications: @Sendable () async -> Void
  var getPendingNotifications: @Sendable () async -> [UNNotificationRequest]
}

// MARK: - Notification Request

struct NotificationRequest: Equatable, Sendable {
  let id: String
  let title: String
  let body: String
  let date: Date
  let userInfo: [String: String]
  
  init(
    id: String,
    title: String,
    body: String,
    date: Date,
    userInfo: [String: String] = [:]
  ) {
    self.id = id
    self.title = title
    self.body = body
    self.date = date
    self.userInfo = userInfo
  }
}

// MARK: - Dependency Registration

extension UserNotificationClient: DependencyKey {
  static let liveValue: UserNotificationClient = {
    let center = UNUserNotificationCenter.current()
    
    return UserNotificationClient(
      requestAuthorization: {
        do {
          return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
          print("Failed to request notification authorization: \(error)")
          return false
        }
      },
      
      getAuthorizationStatus: {
        await center.notificationSettings().authorizationStatus
      },
      
      scheduleExpiryNotification: { item, daysBeforeExpiry in
        guard let expiryDate = item.expiryDate else { return }
        
        let notificationDate = Calendar.current.date(
          byAdding: .day,
          value: -daysBeforeExpiry,
          to: expiryDate
        ) ?? expiryDate
        
        // 通知が過去の日付でないかチェック
        guard notificationDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "ポチからのお知らせ 🐕"
        
        if daysBeforeExpiry == 0 {
          content.body = "「\(item.name)」の賞味期限が今日です！"
        } else {
          content.body = "「\(item.name)」の賞味期限まで\(daysBeforeExpiry)日です"
        }
        
        content.sound = .default
        content.badge = 1
        content.userInfo = [
          "itemId": item.id.uuidString,
          "type": "expiry"
        ]
        
        let dateComponents = Calendar.current.dateComponents(
          [.year, .month, .day, .hour, .minute],
          from: notificationDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
          dateMatching: dateComponents,
          repeats: false
        )
        
        let request = UNNotificationRequest(
          identifier: "expiry-\(item.id.uuidString)-\(daysBeforeExpiry)",
          content: content,
          trigger: trigger
        )
        
        try await center.add(request)
      },
      
      cancelNotification: { identifier in
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
      },
      
      cancelAllNotifications: {
        center.removeAllPendingNotificationRequests()
      },
      
      getPendingNotifications: {
        await center.pendingNotificationRequests()
      }
    )
  }()
  
}

extension DependencyValues {
  var userNotification: UserNotificationClient {
    get { self[UserNotificationClient.self] }
    set { self[UserNotificationClient.self] = newValue }
  }
}

// MARK: - Notification Helper

struct NotificationHelper: Sendable {
  static func scheduleItemNotifications(
    for item: Item,
    daysBeforeExpiry: [Int] = [1, 3],
    using client: UserNotificationClient
  ) async throws {
    // 既存の通知をキャンセル
    for days in daysBeforeExpiry {
      await client.cancelNotification("expiry-\(item.id.uuidString)-\(days)")
    }
    
    // 新しい通知をスケジュール
    for days in daysBeforeExpiry {
      try await client.scheduleExpiryNotification(item, days)
    }
  }
  
  static func cancelItemNotifications(
    for itemId: UUID,
    using client: UserNotificationClient
  ) async {
    let daysToCancel = [0, 1, 2, 3, 5, 7] // 可能性のある全ての日数
    
    for days in daysToCancel {
      await client.cancelNotification("expiry-\(itemId.uuidString)-\(days)")
    }
  }
}
