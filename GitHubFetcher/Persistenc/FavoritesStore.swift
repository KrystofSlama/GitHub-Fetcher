//
//  FavoritesStore.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 26.08.2025.
//

import Foundation

final class FavoritesStore {
    private let d = UserDefaults.standard

    // Favorites
    func loadFavorites() -> [RepoSummary] {
        guard let data = d.data(forKey: "favorites") else { return [] }
        return (try? JSONDecoder().decode([RepoSummary].self, from: data)) ?? []
    }
    func saveFavorites(_ items: [RepoSummary]) {
        if let data = try? JSONEncoder().encode(items) { d.set(data, forKey: "favorites") }
    }

    // Recently opened repos (MRU)
    func loadRecentOpened() -> [RepoSummary] {
        guard let data = d.data(forKey: "recentOpened") else { return [] }
        return (try? JSONDecoder().decode([RepoSummary].self, from: data)) ?? []
    }
    
    func saveRecentOpened(_ items: [RepoSummary]) {
        let trimmed = Array(items.prefix(20))
        if let data = try? JSONEncoder().encode(trimmed) { d.set(data, forKey: "recentOpened") }
    }
}
