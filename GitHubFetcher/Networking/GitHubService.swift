//
//  GitHubService.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 17.08.2025.
//

import Foundation

// MARK: - Errors
enum GitHubAPIError: Error {
    case unauthorized
    case badRepoName
    case notFound
    case transport(Error)
    case decoding
    case unowned
    case unknown
    case network
    case rateLimited
    case badRepoFormat
}

final class GitHubService {
    private let session: URLSession
    private let base = URL(string: "https://api.github.com")!
    private let graphql = URL(string: "https://api.github.com/graphql")!
    private let tokenStore: TokenStore

    var token: String? { tokenStore.getToken() }

    init(tokenStore: TokenStore = KeychainHelper.shared, session: URLSession = .shared) {
        self.tokenStore = tokenStore
        self.session = session
    }

    func updateToken(_ newToken: String) {
        tokenStore.saveToken(newToken)
    }
    
    // MARK: -Basic functions
    private func logRateLimit(from response: HTTPURLResponse) {
        if let remaining = response.value(forHTTPHeaderField: "X-RateLimit-Remaining"),
           let limit = response.value(forHTTPHeaderField: "X-RateLimit-Limit") {
            print("GitHub API remaining: \(remaining)/\(limit)")
        }
    }
    
    private func request(_ url: URL) -> URLRequest {
        var r = URLRequest(url: url)
        r.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        if let token { r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        return r
    }
    
    // MARK: -Searching
    func searchRepos(query: String, perPage: Int = 20) async throws -> [RepoSummary] {
        // Search by name + description
        let q = "\(query) in:name,description"
        
        // Url that is goigng to be sent
        var comps = URLComponents(url: base.appendingPathComponent("search/repositories"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            .init(name: "q", value: q),
            .init(name: "per_page", value: String(perPage)),
            .init(name: "sort", value: "stars")
        ]
        // Request
        let (data, resp) = try await session.data(for: request(comps.url!))
        
        guard let http = resp as? HTTPURLResponse else { throw GitHubAPIError.network }
        logRateLimit(from: http)
        // Error Handling
        guard http.statusCode == 200 else {
            if http.statusCode == 403 { throw GitHubAPIError.rateLimited }
            if http.statusCode == 404 { throw GitHubAPIError.notFound }
            throw GitHubAPIError.unknown
        }
        
        struct R: Decodable {
            struct Item: Decodable {
                let id: Int;
                let full_name: String;
                let description: String?
                let stargazers_count: Int
                let owner: Owner;
                let html_url: String;
                let updated_at: String?
                struct Owner: Decodable { let login: String }
            }
            let items: [Item]
        }
        
        let r = try JSONDecoder().decode(R.self, from: data)
        let iso = ISO8601DateFormatter()
        // Returning [RepoSumarry]
        return r.items.map {
            RepoSummary(
                id: $0.id, fullName: $0.full_name, description: $0.description,
                stargazersCount: $0.stargazers_count, ownerLogin: $0.owner.login,
                htmlURL: URL(string: $0.html_url)!, updatedAt: $0.updated_at.flatMap { iso.date(from: $0) }
            )
        }
    }
    
    // Refractor this
    // MARK: -Fetching repo data
    func fetchRepoDetailGraphQL(fullName: String) async throws -> RepoDetail {
        guard let token, !token.isEmpty else { throw GitHubAPIError.unauthorized }

        // Split "owner/name"
        let parts = fullName.split(separator: "/", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { throw GitHubAPIError.badRepoFormat }
        let owner = parts[0], name = parts[1]

        struct Body: Encodable { let query: String; let variables: [String: String] }
        let query = """
        query RepoBasics($owner: String!, $name: String!) {
          repository(owner: $owner, name: $name) {
            databaseId
            nameWithOwner
            description
            url
            updatedAt
            stargazerCount
            forkCount
            issues(states: OPEN) { totalCount }
            pullRequests(states: OPEN) { totalCount }
            watchers { totalCount }
          }
        }
        """

        var req = URLRequest(url: graphql)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        req.httpBody = try JSONEncoder().encode(Body(query: query, variables: ["owner": owner, "name": name]))

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw GitHubAPIError.network }
        logRateLimit(from: http)

        switch http.statusCode {
        case 200...299:
            break
        case 401:
            if let s = String(data: data, encoding: .utf8) { print("GraphQL 401:", s) }
            throw GitHubAPIError.unauthorized
        case 403:
            if let s = String(data: data, encoding: .utf8) { print("GraphQL 403:", s) }
            throw GitHubAPIError.rateLimited
        case 404:
            throw GitHubAPIError.notFound
        default:
            if let s = String(data: data, encoding: .utf8) { print("GraphQL error body:", s) }
            throw GitHubAPIError.unknown
        }

        // Decode GraphQL JSON (handles 200 with logical errors)
        struct GQL: Decodable {
            struct DataObj: Decodable {
                struct Repo: Decodable {
                    let databaseId: Int
                    let nameWithOwner: String
                    let description: String
                    let url: URL
                    let updatedAt: Date
                    let stargazerCount: Int
                    let forkCount: Int
                    struct Count: Decodable { let totalCount: Int }
                    let issues: Count
                    let pullRequests: Count
                    let watchers: Count
                }
                let repository: Repo?
            }
            let data: DataObj
            let errors: [GQLError]?
        }
        struct GQLError: Decodable { let message: String }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let gql = try decoder.decode(GQL.self, from: data)

        if let errs = gql.errors, !errs.isEmpty {
            // GraphQL often returns 200 with an "errors" array
            print("GraphQL logical errors:", errs.map(\.message).joined(separator: " | "))
            throw GitHubAPIError.unknown
        }

        guard let r = gql.data.repository else {
            throw GitHubAPIError.notFound
        }

        return RepoDetail(
            id: r.databaseId,
            fullName: r.nameWithOwner,
            rDescription: r.description,
            htmlURL: r.url,
            starsCount: r.stargazerCount,
            forksCount: r.forkCount,
            openIssuesCount: r.issues.totalCount,
            openPRsCount: r.pullRequests.totalCount,
            watchersCount: r.watchers.totalCount
        )
    }
}

extension GitHubService: GitHubGraphQLServicing {}
