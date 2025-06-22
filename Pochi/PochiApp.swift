//
//  PochiApp.swift
//  Pochi
//
//  Created by 田川展也 on 2025/06/21.
//

import ComposableArchitecture
import SwiftUI

@main
struct PochiApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                }
            )
        }
    }
}
