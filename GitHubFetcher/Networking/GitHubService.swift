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
    private let token: String?
    
    init(token: String? = nil, session: URLSession = .shared) {
        self.token = token
        self.session = session
    }
    
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
    
    // --- REST you already had ---
    
    func getRepo(owner: String, name: String) async throws -> RepoSummary {
        let url = base.appendingPathComponent("repos/\(owner)/\(name)")
        let (data, resp) = try await session.data(for: request(url))
        guard let http = resp as? HTTPURLResponse else { throw GitHubAPIError.network }
        logRateLimit(from: http)
        switch http.statusCode {
        case 200:
            struct R: Decodable {
                let id: Int; let full_name: String; let description: String?
                let stargazers_count: Int
                let owner: Owner; let html_url: String; let updated_at: String?
                struct Owner: Decodable { let login: String }
            }
            let r = try JSONDecoder().decode(R.self, from: data)
            let iso = ISO8601DateFormatter()
            return RepoSummary(
                id: r.id, fullName: r.full_name, description: r.description,
                stargazersCount: r.stargazers_count, ownerLogin: r.owner.login,
                htmlURL: URL(string: r.html_url)!, updatedAt: r.updated_at.flatMap { iso.date(from: $0) }
            )
        case 404: throw GitHubAPIError.notFound
        case 403: throw GitHubAPIError.rateLimited
        default: throw GitHubAPIError.unknown
        }
    }
    
    func searchRepos(query: String, perPage: Int = 20) async throws -> [RepoSummary] {
        // Search by name + description
        let q = "\(query) in:name,description"
        var comps = URLComponents(url: base.appendingPathComponent("search/repositories"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            .init(name: "q", value: q),
            .init(name: "per_page", value: String(perPage)),
            .init(name: "sort", value: "stars")
        ]
        let (data, resp) = try await session.data(for: request(comps.url!))
        guard let http = resp as? HTTPURLResponse else { throw GitHubAPIError.network }
        logRateLimit(from: http)
        guard http.statusCode == 200 else {
            if http.statusCode == 403 { throw GitHubAPIError.rateLimited }
            if http.statusCode == 404 { throw GitHubAPIError.notFound }
            throw GitHubAPIError.unknown
        }
        
        struct R: Decodable {
            struct Item: Decodable {
                let id: Int; let full_name: String; let description: String?
                let stargazers_count: Int
                let owner: Owner; let html_url: String; let updated_at: String?
                struct Owner: Decodable { let login: String }
            }
            let items: [Item]
        }
        
        let r = try JSONDecoder().decode(R.self, from: data)
        let iso = ISO8601DateFormatter()
        return r.items.map {
            RepoSummary(
                id: $0.id, fullName: $0.full_name, description: $0.description,
                stargazersCount: $0.stargazers_count, ownerLogin: $0.owner.login,
                htmlURL: URL(string: $0.html_url)!, updatedAt: $0.updated_at.flatMap { iso.date(from: $0) }
            )
        }
    }
    
    // --- NEW: GraphQL fetch for basics (name, stars, open issues) ---
    // 2–5) Updated GraphQL function
    func getRepoBasicsGraphQL(owner: String, name: String) async throws -> RepoBasicsDetail {
        guard let token, !token.isEmpty else { throw GitHubAPIError.unauthorized }
        
        struct Body: Encodable { let query: String; let variables: [String: String] }
        let query =
        """
        query RepoBasics($owner: String!, $name: String!) {
          repository(owner: $owner, name: $name) {
            databaseId
            nameWithOwner
            description
            stargazerCount
            owner { login }
            url
            updatedAt
            issues(states: OPEN) { totalCount }
          }
        }
        """
        
        var req = URLRequest(url: graphql)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // 5) Optional but recommended by GitHub
        req.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        req.httpBody = try JSONEncoder().encode(Body(query: query, variables: ["owner": owner, "name": name]))
        
        
        
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw GitHubAPIError.network }
        logRateLimit(from: http)
        
        print("------req------: \(req)")
        print("------resp-----: \(resp)")
        print("-------Data------: \(data)")
        print("-----http-----: \(http)")
        // 3) Map status codes, 4) print body when bad
        switch http.statusCode {
        case 200...299:
            break
        case 401:
            if let s = String(data: data, encoding: .utf8) { print("GraphQL 401 body:", s) }
            throw GitHubAPIError.unauthorized
        case 403:
            if let s = String(data: data, encoding: .utf8) { print("GraphQL 403 body:", s) }
            throw GitHubAPIError.rateLimited
        case 404:
            throw GitHubAPIError.notFound
        default:
            if let s = String(data: data, encoding: .utf8) { print("GraphQL error body:", s) }
            throw GitHubAPIError.unknown
        }
        
        struct GQLResponse: Decodable {
            struct DataObj: Decodable {
                struct Repo: Decodable {
                    let databaseId: Int?
                    let nameWithOwner: String
                    let description: String?
                    let stargazerCount: Int
                    struct Owner: Decodable { let login: String }
                    let owner: Owner
                    let url: URL
                    let updatedAt: Date
                    struct Issues: Decodable { let totalCount: Int }
                    let issues: Issues
                }
                let repository: Repo?
            }
            let data: DataObj
            let errors: [GQLError]?
        }
        struct GQLError: Decodable { let message: String }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let gql = try decoder.decode(GQLResponse.self, from: data)
        print("---- GraphQL response ----: \(String(data: data, encoding: .utf8) ?? "(no JSON)")")
        if let errs = gql.errors, !errs.isEmpty {
            print("GraphQL logical errors:", errs.map(\.message).joined(separator: " | "))
            // Often still HTTP 200 with errors array
            throw GitHubAPIError.decoding
        }
        
        guard let r = gql.data.repository, let dbID = r.databaseId else {
            throw GitHubAPIError.notFound
        }
        
        let summary = RepoSummary(
            id: dbID,
            fullName: r.nameWithOwner,
            description: r.description,
            stargazersCount: r.stargazerCount,
            ownerLogin: r.owner.login,
            htmlURL: r.url,
            updatedAt: r.updatedAt
        )
        return RepoBasicsDetail(summary: summary, openIssuesCount: r.issues.totalCount)
    }
    
    
    
    
    
    
    
    // Dashboard call GraphQL
    func getDashboardData(repoName: String) async throws -> RepoDetail {
        guard let token, !token.isEmpty else { throw GitHubAPIError.unauthorized }
        
        let parts = repoName.split(separator: "/", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { throw GitHubAPIError.badRepoFormat }
        let owner = parts[0], name = parts[1]
        
        struct Body: Encodable { let query: String; let variables: [String: String] }
        
        let query =
        """
        query RepoBasics($owner: String!, $name: String!) {
          repository(owner: $owner, name: $name) {
            databaseId
            nameWithOwner
            description
            stargazerCount
            owner { login }
            url
            updatedAt
            issues(states: OPEN) { totalCount }
          }
        }
        """
        
        var req = URLRequest(url: URL(string: "https://api.github.com/graphql")!)
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(Body(query: query, variables: ["owner": owner, "name": name]))
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        
        guard let http = resp as? HTTPURLResponse else { throw GitHubAPIError.network }
        logRateLimit(from: http)
        
        print("------req------: \(req)")
        print("------resp-----: \(resp)")
        print("-------Data------: \(data)")
        print("-----http-----: \(http)")
        
        switch http.statusCode {
        case 200...299:
            break
        case 401:
            if let s = String(data: data, encoding: .utf8) { print("GraphQL 401 body:", s) }
            throw GitHubAPIError.unauthorized
        case 403:
            if let s = String(data: data, encoding: .utf8) { print("GraphQL 403 body:", s) }
            throw GitHubAPIError.rateLimited
        case 404:
            throw GitHubAPIError.notFound
        default:
            if let s = String(data: data, encoding: .utf8) { print("GraphQL error body:", s) }
            throw GitHubAPIError.unknown
        }
        
        struct GQLIssues: Decodable { let totalCount: Int }
        struct GQLRepo: Decodable {
            let databaseId: Int?
            let url: URL
            let nameWithOwner: String
            let stargazerCount: Int
            let issues: GQLIssues
        }
        struct GQLData: Decodable { let repository: GQLRepo }
        struct GQLResponse: Decodable { let data: GQLData }
        
        let decoded = try JSONDecoder().decode(GQLResponse.self, from: data)
        let r = decoded.data.repository
        
        let openIssuesOnly = r.issues.totalCount
        
        
        return RepoDetail(
            id: r.databaseId ?? -1,
            fullName: r.nameWithOwner,
            rDescription: r.nameWithOwner,
            htmlURL: r.url,
            starsCount: r.stargazerCount,
            forksCount: 109,
            openIssuesCount: 110,
            openPRsCount: 111,
            watchersCount: 112
        )
        
    }
    
    
    
    
    

    // Again
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
            openIssuesCount: r.issues.totalCount,       // issues only ✅
            openPRsCount: r.pullRequests.totalCount,    // PRs ✅
            watchersCount: r.watchers.totalCount
        )
    }
}

extension GitHubService: GitHubGraphQLServicing {}
