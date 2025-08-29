//
//  RepoDashboardViewModel.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 23.08.2025.
//

import Foundation
import SwiftData

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var detail: RepoBasicsDetail?
    @Published var isLoading = false
    @Published var errorText: String?

    private let api: GitHubService
    private let owner: String
    private let name: String
    
    
    @Published var repoDetail: RepoDetail?

    init(owner: String, name: String, api: GitHubService) {
        self.owner = owner
        self.name = name
        self.api = api
    }

    func load() async {
        isLoading = true
        errorText = nil
        defer { isLoading = false }
        do {
            detail = try await api.getRepoBasicsGraphQL(owner: owner, name: name)
        } catch {
            errorText = (error as NSError).localizedDescription
        }
    }
    
    func loadNew(repoName: String) async {
        isLoading = true
        errorText = nil
        defer { isLoading = false }
        do {
            repoDetail = try await api.getDashboardData(repoName: repoName)
        } catch {
            errorText = (error as NSError).localizedDescription
        }
    }
}

@MainActor
func createRepoBaselineIfNeeded(
    fullName: String,                    // "owner/name"
    token: String,
    context: ModelContext,
    fetch: (String, String) async throws -> RepoDetail // (fullName, token) -> RepoDetail
) async throws -> TrackedRepo {
    guard !token.isEmpty else { throw GitHubAPIError.unauthorized }

    // 1) If it already exists, return it untouched.
    if let repo = try context.fetch(
        FetchDescriptor<TrackedRepo>(predicate: #Predicate { $0.fullName == fullName })
    ).first {
        return repo
    }


    // 2) Fetch from GitHub
    let detail: RepoDetail
    do {
        detail = try await fetch(fullName, token)
    } catch {
        throw GitHubAPIError.transport(error)
    }

    // 3) Insert baseline
    let now = Date()
    let repo = TrackedRepo(
        databaseId: detail.id,
        fullName: detail.fullName,
        rDescription: detail.rDescription,
        htmlURL: detail.htmlURL,
        stars: detail.starsCount,
        openIssues: detail.openIssuesCount,
        openPRs: detail.openPRsCount,
        forks: detail.forksCount,
        watchers: detail.watchersCount,
        lastFetchedAt: now
    )
    context.insert(repo)
    try context.save()
    return repo
}
