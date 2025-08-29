//
//  GitHubFetcherApp.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 17.08.2025.
//

import SwiftUI

@main
struct GitHubFetcherApp: App {
    @State private var container = AppContainer.make()

    var body: some Scene {
        WindowGroup {
            SearchView(vm: SearchViewModel(api: container.github, store: container.favorites))
        }
        .modelContainer(container.modelContainer)   // ← inject once, globally
    }
}
