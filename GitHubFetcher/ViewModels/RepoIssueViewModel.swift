//
//  RepoIssueViewModel.swift
//  GitHubFetcher
//
//  Created by OpenAI Assistant on 2025-09-??.
//

import Foundation

@MainActor
final class RepoIssueViewModel: ObservableObject {
    // MARK: - Published state
    @Published private(set) var issue: RepoIssueDetail?
    @Published private(set) var isLoading = false
    @Published var errorText: String?

    // MARK: - Dependencies
    private let service: GitHubService
    private let repoFullName: String
    let issueNumber: Int

    private var hasLoadedOnce = false

    // MARK: - Init
    init(repoFullName: String, issueNumber: Int, service: GitHubService, initialIssue: RepoIssueDetail? = nil) {
        self.repoFullName = repoFullName
        self.issueNumber = issueNumber
        self.service = service
        self.issue = initialIssue
        if initialIssue != nil {
            hasLoadedOnce = true
        }
    }

    // MARK: - Loading
    func load(force: Bool = false) async {
        if isLoading { return }
        if !force, hasLoadedOnce, issue != nil { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let detail = try await service.fetchIssueData(fullName: repoFullName, number: issueNumber)
            issue = detail
            errorText = nil
            hasLoadedOnce = true
        } catch GitHubAPIError.unauthorized {
            errorText = "Missing or invalid GitHub token. Update it in Settings to load issue details."
        } catch GitHubAPIError.notFound {
            errorText = "Issue #\(issueNumber) could not be found."
        } catch {
            errorText = "Failed to load issue details. Check your connection and try again."
        }
    }

    func refresh() async {
        await load(force: true)
    }
}
