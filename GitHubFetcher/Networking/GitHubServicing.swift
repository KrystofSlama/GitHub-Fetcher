//
//  GitHubServicing.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 25.08.2025.
//


import Foundation

protocol GitHubServicingg {
    func fetchRepoDetail(fullName: String, token: String) async throws -> RepoDetail
}

struct GitHubServicing {
    func fetchRepoDetail(fullName: String, token: String) async throws -> RepoDetail {
        let parts = fullName.split(separator: "/")
        guard parts.count == 2 else { throw GitHubAPIError.badRepoName }
        let owner = parts[0], name = parts[1]

        var req = URLRequest(url: URL(string: "https://api.github.com/repos/\(owner)/\(name)")!)
        if !token.isEmpty { req.setValue("token \(token)", forHTTPHeaderField: "Authorization") }
        req.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else { throw GitHubAPIError.transport(NSError()) }
            guard (200...299).contains(http.statusCode) else {
                if http.statusCode == 404 { throw GitHubAPIError.notFound }
                if http.statusCode == 401 { throw GitHubAPIError.unauthorized }
                throw GitHubAPIError.transport(NSError(domain: "HTTP \(http.statusCode)", code: http.statusCode))
            }

            struct RESTRepo: Decodable {
                let id: Int
                let full_name: String
                let html_url: String
                let stargazers_count: Int
                let forks_count: Int
                let open_issues_count: Int
                let subscribers_count: Int
            }
            let rest = try JSONDecoder().decode(RESTRepo.self, from: data)
            return RepoDetail(
                id: rest.id,
                fullName: rest.full_name,
                rDescription: rest.full_name,
                htmlURL: URL(string: rest.html_url)!,
                starsCount: rest.forks_count,
                forksCount: rest.open_issues_count,
                openIssuesCount: rest.subscribers_count,
                openPRsCount: 1,
                watchersCount: 2,
                
            )
        } catch let e as GitHubAPIError {
            throw e
        } catch {
            throw GitHubAPIError.transport(error)
        }
    }
}
