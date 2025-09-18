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
    
    // Token
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
    // MARK: -Fetching Repo data
    
    // RepoDashboard data
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
        
            issues(states: OPEN, first: 10, orderBy: {field: CREATED_AT, direction: DESC}) {
              totalCount
              nodes {
                databaseId
                number
                title
                url
              }
            }
        
            pullRequests(states: OPEN) { totalCount }
            watchers { totalCount }
            defaultBranchRef {
              target {
                ... on Commit {
                  history(first: 10) {
                    nodes {
                      oid
                      messageHeadline
                      url
                    }
                  }
                }
              }
            }
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
                    struct IssueNode: Decodable {
                        let databaseId: Int
                        let number: Int
                        let title: String
                        let url: URL
                    }
                    struct Issues: Decodable {
                        let totalCount: Int
                        let nodes: [IssueNode]
                    }
                    let issues: Issues
                    struct Count: Decodable { let totalCount: Int }
                    let pullRequests: Count
                    let watchers: Count
                    struct DefaultBranchRef: Decodable {
                        struct Target: Decodable {
                            struct History: Decodable {
                                struct CommitNode: Decodable {
                                    let oid: String
                                    let messageHeadline: String
                                    let url: URL
                                }
                                let nodes: [CommitNode]
                            }
                            let history: History?
                        }
                        let target: Target?
                    }
                    let defaultBranchRef: DefaultBranchRef?
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

        let issues = r.issues.nodes.map { RepoIssue(id: $0.databaseId, number: $0.number, title: $0.title, url: $0.url) }
        let commits = r.defaultBranchRef?.target?.history?.nodes.map {
            RepoCommit(id: $0.oid, message: $0.messageHeadline, url: $0.url)
        } ?? []
        
        return RepoDetail(
            id: r.databaseId,
            fullName: r.nameWithOwner,
            rDescription: r.description,
            htmlURL: r.url,
            starsCount: r.stargazerCount,
            forksCount: r.forkCount,
            openIssuesCount: r.issues.totalCount,
            openPRsCount: r.pullRequests.totalCount,
            watchersCount: r.watchers.totalCount,
            issues: issues,
            commits: commits
        )
    }
    
    // Issue data
    func fetchIssueData(fullName: String, number: Int) async throws -> RepoIssueDetail {
        guard let token, !token.isEmpty else { throw GitHubAPIError.unauthorized }
        
        struct Body: Encodable { let query: String; let variables: Vars }
        struct Vars: Encodable { let owner: String; let number: Int }
        
        let query = """
                query IssueDetail($owner:String!, $name:String!, $number:Int!) {
                  repository(owner:$owner, name:$name) {
                    issue(number:$number) {
                      id number title url state createdAt
                      author { login }
                      labels(first:50) { nodes { id name color } }
                      comments { totalCount }
                    }
                  }
                }
                """
        
        let body = Body(query: query, variables: .init(owner: fullName, number: number))
        
        var req = URLRequest(url: graphql)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        req.httpBody = try JSONEncoder().encode(body)

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw GitHubAPIError.network }
        logRateLimit(from: http)
        
        struct Resp: Decodable {
                    struct D: Decodable {
                        struct Repo: Decodable {
                            struct Issue: Decodable {
                                let id: String
                                let number: Int
                                let title: String
                                let url: URL
                                let state: String
                                let createdAt: String
                                struct A: Decodable { let login: String? }
                                let author: A?
                                struct LWrap: Decodable { struct L: Decodable { let id: String; let name: String; let color: String } ; let nodes: [L] }
                                let labels: LWrap
                                struct C: Decodable { let totalCount: Int }
                                let comments: C
                            }
                            let issue: Issue?
                        }
                        let repository: Repo?
                    }
                    let data: D
                }

                let decoded = try JSONDecoder().decode(Resp.self, from: data)
                guard let n = decoded.data.repository?.issue else { throw GitHubAPIError.decoding }

                let created = ISO8601DateFormatter().date(from: n.createdAt) ?? .distantPast

                return RepoIssueDetail(
                    id: n.id,
                    number: n.number,
                    title: n.title,
                    state: n.state,
                    author: n.author?.login,
                    createdAt: created,
                    commentsCount: n.comments.totalCount,
                    labels: n.labels.nodes.map { GHLabel(id: $0.id, name: $0.name, color: $0.color) },
                    url: n.url
                )
    }
}

extension GitHubService: GitHubGraphQLServicing {}
