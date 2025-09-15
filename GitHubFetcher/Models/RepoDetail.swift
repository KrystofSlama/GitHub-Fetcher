//
//  RepoDetail.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 23.08.2025.
//

import SwiftData
import Foundation


// MARK: -RepoDetail for dashboard
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
    let issues: [RepoIssue]
    let commits: [RepoCommit]
}

//Deltas for dashboard
struct RepoDelta: Hashable {
    let stars: Int?
    let openIssues: Int
    let openPRs: Int
    let forks: Int
    let watchers: Int
    let since: Date
}


//MARK: -Issues
struct RepoIssue: Decodable, Identifiable, Hashable {
    let id: Int
    let number: Int
    let title: String
    let url: URL
}

struct GHIssue: Identifiable, Hashable {
    let id: String
    let number: Int
    let title: String
    let state: String
    let author: String?
    let createdAt: Date
    let commentsCount: Int
    let labels: [GHLabel]
    let url: URL
}


//MARK: -Commits
struct RepoCommit: Decodable, Identifiable, Hashable {
    let id: String        // commit SHA
    let message: String
    let url: URL
}


//MARK: -Others
//Labels
struct GHLabel: Identifiable, Hashable {
    let id: String
    let name: String
    let color: String
}
