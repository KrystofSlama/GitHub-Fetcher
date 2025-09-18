//
//  RepoIssueView.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 15.09.2025.
//

import SwiftData
import SwiftUI

struct RepoIssueView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var viewModel: RepoDashboardViewModel

    private let repoName: String
    private let issueNumber: Int

    private var issueDetail: RepoIssueDetail? { viewModel.issueDetail(for: issueNumber) }
    private var isLoading: Bool { viewModel.isIssueDetailLoading(issueNumber) }
    private var errorText: String? { viewModel.issueDetailError(for: issueNumber) }

    init(viewModel: RepoDashboardViewModel, repoName: String, issueNumber: Int) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        self.repoName = repoName
        self.issueNumber = issueNumber
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                content
            }
            .padding()
        }
        .background(Color(.systemGray6))
        .navigationTitle("#\(issueNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadIssueDetail(number: issueNumber) }
        .refreshable { await viewModel.refreshIssueDetail(number: issueNumber) }
        .toolbar {
            if let url = issueDetail?.url {
                ToolbarItem(placement: .topBarTrailing) {
                    Link("Open on GitHub", destination: url)
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let message = errorText {
                errorBanner(message)
                    .padding()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let issue = issueDetail {
            VStack(alignment: .leading, spacing: 12) {
                Text(issue.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)

                Text(repoName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    stateBadge(issue.state)
                    Spacer()
                    Text(issue.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let author = issue.author {
                    Label("Opened by \(author)", systemImage: "person")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Label("\(issue.commentsCount) comment\(issue.commentsCount == 1 ? "" : "s")", systemImage: "text.bubble")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !issue.labels.isEmpty {
                    labelsSection(issue.labels)
                }

                Link("View issue on GitHub", destination: issue.url)
                    .font(.body)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
        } else if isLoading {
            ProgressView("Loading…")
                .frame(maxWidth: .infinity)
                .padding(.top, 32)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.secondary)
                Text("Issue details are unavailable.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 32)
        }
    }

    @ViewBuilder
    private func labelsSection(_ labels: [GHLabel]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Labels")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(labels) { label in
                        Text(label.name)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(color(from: label.color).opacity(colorScheme == .dark ? 0.3 : 0.2)))
                            .overlay(
                                Capsule()
                                    .stroke(color(from: label.color), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func stateBadge(_ state: String) -> some View {
        Text(state.uppercased())
            .font(.caption)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(stateColor(state).opacity(colorScheme == .dark ? 0.3 : 0.2))
            )
            .overlay(
                Capsule()
                    .stroke(stateColor(state), lineWidth: 1)
            )
    }

    private func stateColor(_ state: String) -> Color {
        switch state.lowercased() {
        case "open":
            return .green
        case "closed":
            return .red
        default:
            return .gray
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(color: Color(.black).opacity(colorScheme == .dark ? 0.4 : 0.1), radius: 6, x: 0, y: 3)
    }

    private func color(from hex: String) -> Color {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard sanitized.count == 6, let value = Int(sanitized, radix: 16) else {
            return .gray
        }
        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0
        return Color(red: red, green: green, blue: blue)
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.callout)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(colorScheme == .dark ? 0.25 : 0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    let container = try! ModelContainer(for: TrackedRepo.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let previewService = PreviewGraphQLService()
    let vm = RepoDashboardViewModel(
        fullName: "apple/swift",
        context: container.mainContext,
        service: previewService
    )
    vm.injectIssueDetailForPreview(
        RepoIssueDetail(
            id: "MDU6SXNzdWUx",
            number: 12345,
            title: "Sample issue title used for previews",
            state: "open",
            author: "swift-developer",
            createdAt: Date(),
            commentsCount: 42,
            labels: [
                GHLabel(id: "MDU6TGFiZWwx", name: "bug", color: "d73a4a"),
                GHLabel(id: "MDU6TGFiZWwy", name: "enhancement", color: "a2eeef")
            ],
            url: URL(string: "https://github.com/apple/swift/issues/12345")!
        )
    )

    return NavigationStack {
        RepoIssueView(
            viewModel: vm,
            repoName: "apple/swift",
            issueNumber: 12345
        )
    }
}

#if DEBUG
private struct PreviewGraphQLService: GitHubGraphQLServicing {
    func fetchRepoDetailGraphQL(fullName: String) async throws -> RepoDetail {
        RepoDetail(
            id: 1,
            fullName: fullName,
            rDescription: "",
            htmlURL: URL(string: "https://github.com/\(fullName)")!,
            starsCount: 0,
            forksCount: 0,
            openIssuesCount: 0,
            openPRsCount: 0,
            watchersCount: 0,
            issues: [],
            commits: []
        )
    }

    func fetchIssueData(fullName: String, number: Int) async throws -> RepoIssueDetail {
        RepoIssueDetail(
            id: "preview",
            number: number,
            title: "Preview Issue",
            state: "open",
            author: "previewer",
            createdAt: Date(),
            commentsCount: 0,
            labels: [],
            url: URL(string: "https://github.com/\(fullName)/issues/\(number)")!
        )
    }
}
#endif
