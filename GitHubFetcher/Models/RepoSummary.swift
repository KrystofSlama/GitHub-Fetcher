//
//  RepoSummary.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 17.08.2025.
//

import Foundation

struct RepoSummary: Identifiable, Codable, Hashable {
    let id: Int
    let fullName: String       // "owner/name"
    let description: String?
    let stargazersCount: Int
    let ownerLogin: String
    let htmlURL: URL
    let updatedAt: Date?
}

extension RepoSummary {
    var ownerAndName: (owner: String, name: String)? {
        let parts = fullName.split(separator: "/")
        guard parts.count == 2 else { return nil }
        return (String(parts[0]), String(parts[1]))
    }
}
