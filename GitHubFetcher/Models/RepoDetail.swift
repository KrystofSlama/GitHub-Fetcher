//
//  RepoDetail.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 23.08.2025.
//

import SwiftData
import Foundation

struct RepoDetail: Decodable, Hashable {
    let id: Int                 // == databaseId
    let fullName: String        // "owner/name"
    let rDescription: String
    let htmlURL: URL
    let starsCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let openPRsCount: Int       // 0 if you’re on REST; real count if GraphQL
    let watchersCount: Int      // subscribers
}

// Computed at refresh time and shown in UI; never stored.
struct RepoDelta: Hashable {
    let stars: Int?
    let openIssues: Int
    let openPRs: Int
    let forks: Int
    let watchers: Int
    let since: Date             // baseline time (repo.lastFetchedAt)
}

// For searchView
struct RepoBasicsDetail: Identifiable, Codable, Hashable {
    let summary: RepoSummary
    let openIssuesCount: Int   // NOTE: REST 'open_issues_count' includes PRs unless you query issues-only.

    // Identifiable passthrough
    var id: Int { summary.id }

    // Convenience for the UI
    var name: String { summary.fullName }
    var stars: Int { summary.stargazersCount }
}
