//
//  AppFeature.swift
//  Pochi
//
//  Created by Pochi Team on 2025/06/21.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .home
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    enum Tab: String, CaseIterable {
        case home = "home"
        case inventory = "inventory"
        case scanner = "scanner"
        case shoppingList = "shoppingList"
        case settings = "settings"

        var title: String {
            switch self {
            case .home: return "ホーム"
            case .inventory: return "在庫"
            case .scanner: return "スキャン"
            case .shoppingList: return "買い物リスト"
            case .settings: return "設定"
            }
        }

        var icon: String {
            switch self {
            case .home: return "house"
            case .inventory: return "archivebox"
            case .scanner: return "camera"
            case .shoppingList: return "cart"
            case .settings: return "gearshape"
            }
        }

        var selectedIcon: String {
            switch self {
            case .home: return "house.fill"
            case .inventory: return "archivebox.fill"
            case .scanner: return "camera.fill"
            case .shoppingList: return "cart.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            }
        }
    }
}

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        TabView(selection: $store.selectedTab) {
            ForEach(AppFeature.Tab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Image(systemName: store.selectedTab == tab ? tab.selectedIcon : tab.icon)
                        Text(tab.title)
                    }
                    .tag(tab)
            }
        }
    }

    @ViewBuilder
    private func tabContent(for tab: AppFeature.Tab) -> some View {
        NavigationStack {
            VStack {
                Image(systemName: tab.selectedIcon)
                    .font(.largeTitle)
                    .foregroundColor(.orange)
                Text("\(tab.title)画面")
                    .font(.title2)
                Text("実装予定")
                    .foregroundColor(.secondary)
            }
            .navigationTitle(tab.title)
        }
    }
}

#Preview("Simple App") {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
