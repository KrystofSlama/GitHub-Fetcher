//
//  RepoDashboardViewModel.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 23.08.2025.
//


import Foundation
import SwiftData

// Use the exact function you added to GitHubService
protocol GitHubGraphQLServicing {
    func fetchRepoDetailGraphQL(fullName: String) async throws -> RepoDetail
}

@MainActor
final class RepooDashboardViewModel: ObservableObject {
    // UI state
    @Published var repo: TrackedRepo?
    @Published var delta: RepoDelta?
    @Published var issues: [RepoIssue] = []
    @Published var commits: [RepoCommit] = []
    @Published var isOffline = false
    @Published var isLoading = false
    @Published var errorText: String?

    // Inputs
    private let fullName: String            // "owner/name" for GraphQL
    private let context: ModelContext
    private let service: GitHubGraphQLServicing
    private let hintedDatabaseId: Int?

    init(
        fullName: String,
        context: ModelContext,
        service: GitHubGraphQLServicing,
        hintedDatabaseId: Int? = nil
    ) {
        self.fullName = fullName
        self.context = context
        self.service = service
        self.hintedDatabaseId = hintedDatabaseId
    }

    // MARK: - Public API
    /// Call in `.task` on view appear, and from `.refreshable`.
    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // 1) API first
            let detail = try await service.fetchRepoDetailGraphQL(fullName: fullName)
            try applyNetworkDetail(detail)
            isOffline = false
            errorText = nil
        } catch {
            // 2) Fallback to SwiftData cache
            await fallbackToSwiftData(error: error)
        }
    }

    
    func refresh() async { await load() }

    // MARK: - Internals
    /// Applies fresh GraphQL data:
    /// - finds existing SD row (by id, then by fullName),
    /// - computes delta if row existed,
    /// - overwrites baseline,
    /// - publishes UI state.
    private func applyNetworkDetail(_ d: RepoDetail) throws {
        // Prefer stable databaseId; fallback to fullName for older rows / first seed
        let existing = try fetchByDatabaseId(d.id) ?? fetchByFullNameNoThrow(d.fullName)

        let now = Date()
        let repoToUse: TrackedRepo
        let computedDelta: RepoDelta?

        if let r = existing {
            // Compute "since last refresh" delta
            computedDelta = RepoDelta(
                stars: d.starsCount - r.stars,
                openIssues: d.openIssuesCount - r.openIssues,
                openPRs: d.openPRsCount - r.openPRs,
                forks: d.forksCount - r.forks,
                watchers: d.watchersCount - r.watchers,
                since: r.lastFetchedAt
            )

            // Overwrite baseline (and reconcile rename via fullName)
            r.fullName = d.fullName
            r.htmlURL = d.htmlURL
            r.stars = d.starsCount
            r.openIssues = d.openIssuesCount
            r.openPRs = d.openPRsCount
            r.forks = d.forksCount
            r.watchers = d.watchersCount
            r.lastFetchedAt = now

            try context.save()
            repoToUse = r
        } else {
            // First time seen locally → insert baseline; no delta yet
            let r = TrackedRepo(
                databaseId: d.id,
                fullName: d.fullName,
                rDescription: d.rDescription,
                htmlURL: d.htmlURL,
                stars: d.starsCount,
                openIssues: d.openIssuesCount,
                openPRs: d.openPRsCount,
                forks: d.forksCount,
                watchers: d.watchersCount,
                lastFetchedAt: now
            )
            context.insert(r)
            try context.save()
            repoToUse = r
            computedDelta = nil
        }

        // Publish
        self.repo = repoToUse
        self.delta = computedDelta
        self.issues = d.issues
        self.commits = d.commits
    }

    /// API failed → try cached SD; set offline state.
    private func fallbackToSwiftData(error: Error) async {
        let cached: TrackedRepo?
        if let hinted = hintedDatabaseId, let byId = try? fetchByDatabaseId(hinted) {
            cached = byId
        } else {
            cached = fetchByFullNameNoThrow(fullName)
        }

        if let apiError = error as? GitHubAPIError, apiError == .unauthorized {
            applyUnauthorizedFallback(using: cached)
            return
        }

        if let cached {
            self.repo = cached
            self.delta = nil
            self.issues = []
            self.commits = []
            self.isOffline = true
            self.errorText = "Offline/API error – showing last saved data."
        } else {
            self.repo = nil
            self.delta = nil
            self.issues = []
            self.commits = []
            self.isOffline = true
            self.errorText = "Couldn’t load data (no internet & no cached baseline)."
        }
    }

    private func applyUnauthorizedFallback(using cached: TrackedRepo?) {
        if let cached {
            repo = cached
            delta = nil
            issues = []
            commits = []
            isOffline = false
            errorText = "Missing or invalid GitHub token. Update it in Settings to refresh."
        } else {
            repo = nil
            delta = nil
            issues = []
            commits = []
            isOffline = false
            errorText = "Missing or invalid GitHub token. Add one in Settings to load repository details."
        }
    }

    // MARK: - SwiftData helpers

    private func fetchByDatabaseId(_ id: Int) throws -> TrackedRepo? {
        try context.fetch(
            FetchDescriptor<TrackedRepo>(predicate: #Predicate { $0.databaseId == id })
        ).first
    }

    private func fetchByFullNameNoThrow(_ name: String) -> TrackedRepo? {
        (try? context.fetch(
            FetchDescriptor<TrackedRepo>(predicate: #Predicate { $0.fullName == name })
        ).first)
    }
}
