//
//  HapticClient.swift
//  Pochi
//
//  Created by Pochi Team on 2025/06/21.
//

import Dependencies
import Foundation
import UIKit

// MARK: - Haptic Client

struct HapticClient: Sendable {
    var impact: @Sendable (UIImpactFeedbackGenerator.FeedbackStyle) -> Void
    var notification: @Sendable (UINotificationFeedbackGenerator.FeedbackType) -> Void
    var selection: @Sendable () -> Void

    // Convenience methods
    var pochiTap: @Sendable () -> Void { { impact(.light) } }
    var pochiSuccess: @Sendable () -> Void { { notification(.success) } }
    var pochiError: @Sendable () -> Void { { notification(.error) } }
    var pochiWarning: @Sendable () -> Void { { notification(.warning) } }
}

// MARK: - Dependency Registration

extension HapticClient: DependencyKey {
    static let liveValue = HapticClient(
        impact: { style in
            Task { @MainActor in

                let generator = UIImpactFeedbackGenerator(style: style)
                generator.prepare()
                generator.impactOccurred()
            }
        },

        notification: { type in
            Task { @MainActor in
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(type)
            }
        },

        selection: {
            Task { @MainActor in
                let generator = UISelectionFeedbackGenerator()
                generator.prepare()
                generator.selectionChanged()
            }
        }
    )

    static let testValue = HapticClient(
        impact: { _ in },
        notification: { _ in },
        selection: { }
    )
}

extension DependencyValues {
    var haptic: HapticClient {
        get { self[HapticClient.self] }
        set { self[HapticClient.self] = newValue }
    }
}

// MARK: - Haptic Feedback Helper

@MainActor
enum HapticHelper {
    static func pochiRegistered() {
        @Dependency(\.haptic) var haptic
        haptic.pochiSuccess()
    }

    static func pochiScanned() {
        @Dependency(\.haptic) var haptic
        haptic.impact(.medium)
    }

    static func pochiDeleted() {
        @Dependency(\.haptic) var haptic
        haptic.impact(.heavy)
    }

    static func pochiQuantityChanged() {
        @Dependency(\.haptic) var haptic
        haptic.impact(.light)
    }

    static func pochiError() {
        @Dependency(\.haptic) var haptic
        haptic.pochiError()
    }
}
