//
//  RepoStore.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 25.08.2025.
//

import Foundation
import SwiftData

// Persistence/TrackedRepo.swift
@Model
final class TrackedRepo {
    @Attribute(.unique) var databaseId: Int
    var fullName: String
    var rDescription: String
    var htmlURL: URL
    var stars: Int
    var openIssues: Int
    var openPRs: Int
    var forks: Int
    var watchers: Int
    var lastFetchedAt: Date

    init(databaseId: Int, fullName: String, rDescription: String, htmlURL: URL,
         stars: Int, openIssues: Int, openPRs: Int, forks: Int, watchers: Int,
         lastFetchedAt: Date = .now) {
        self.databaseId = databaseId
        self.fullName = fullName
        self.rDescription = rDescription
        self.htmlURL = htmlURL
        self.stars = stars
        self.openIssues = openIssues
        self.openPRs = openPRs
        self.forks = forks
        self.watchers = watchers
        self.lastFetchedAt = lastFetchedAt
    }
}

extension TrackedRepo {
    var owner: String {
        fullName.split(separator: "/").first.map(String.init) ?? fullName
    }
    var name: String {
        fullName.split(separator: "/").last.map(String.init) ?? fullName
    }
}
