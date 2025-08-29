//
//  SearchViewModel.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 17.08.2025.
//

import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [RepoSummary] = []

    // Keep array for persistence/order, but track identity via ids
    @Published private(set) var favorites: [RepoSummary] = []
    private var favoriteIds = Set<Int>()

    @Published var recentOpened: [RepoSummary] = []
    @Published var isLoading = false
    @Published var errorText: String?
    @Published var quickOpenCandidate: (owner: String, name: String)?

    private let api: GitHubService
    private let store: FavoritesStore

    init(api: GitHubService, store: FavoritesStore) {
        self.api = api
        self.store = store

        let loadedFavs = store.loadFavorites()
        self.favorites = loadedFavs
        self.favoriteIds = Set(loadedFavs.map { $0.id })

        self.recentOpened = store.loadRecentOpened()
    }

    

    // MARK: - Search
    func searchNow() async {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { results = []; errorText = nil; return }
        errorText = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await api.searchRepos(query: q)
            results = fetched
            absorb(fetched)
        } catch GitHubAPIError.rateLimited {
            results = []; errorText = "Rate limit reached. Try again soon or add a token."
        } catch {
            results = []; errorText = "Search failed. Check your connection."
        }
    }

    // MARK: - Open History
    func markOpened(_ repo: RepoSummary) {
        recentOpened.removeAll { $0.id == repo.id }
        recentOpened.insert(repo, at: 0)
        store.saveRecentOpened(recentOpened)
    }

    // MARK: - Favorites (id-based)
    func isFavorite(_ repo: RepoSummary) -> Bool {
        favoriteIds.contains(repo.id)
    }

    func toggleFavorite(_ repo: RepoSummary) {
        if favoriteIds.contains(repo.id) {
            // remove
            favoriteIds.remove(repo.id)
            favorites.removeAll { $0.id == repo.id }
        } else {
            // add (or refresh if present for any reason)
            addOrUpdateFavorite(repo)
        }
        store.saveFavorites(favorites)
    }

    // Use this whenever you receive a fresher copy of a repo (e.g., from search)
    func addOrUpdateFavorite(_ repo: RepoSummary) {
        if let idx = favorites.firstIndex(where: { $0.id == repo.id }) {
            favorites[idx] = repo
        } else {
            favorites.append(repo)
        }
        favoriteIds.insert(repo.id)
    }
    
    // Updating favorits
    private func absorb(_ repos: [RepoSummary]) {
        var favs = favorites
        var recs = recentOpened
        var changedFavs = false
        var changedRecs = false

        for r in repos {
            if let i = favs.firstIndex(where: { $0.id == r.id }) {
                if favs[i] != r { favs[i] = r; changedFavs = true }
            }
            if let j = recs.firstIndex(where: { $0.id == r.id }) {
                if recs[j] != r { recs[j] = r; changedRecs = true }
            }
        }

        if changedFavs {
            favorites = favs
            store.saveFavorites(favorites)
        }
        if changedRecs {
            recentOpened = recs
            store.saveRecentOpened(recentOpened)
        }
    }
}
