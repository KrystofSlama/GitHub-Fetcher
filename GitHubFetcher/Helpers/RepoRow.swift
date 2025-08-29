//
//  RepoRow.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 21.08.2025.
//

import SwiftUI

struct RepoRow: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let repo: RepoSummary
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        
            
            HStack(spacing: 12) {
                // Front
                Image(systemName: "folder.fill")
                    .font(.title3)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                // Middle
                VStack(alignment: .leading, spacing: 4) {
                    Text(repo.fullName)
                        .font(.headline)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    if let d = repo.description, !d.isEmpty {
                        Text(d)
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .lineLimit(1)
                    }
                    HStack(spacing: 8) {
                        Label("\(repo.stargazersCount)", systemImage: "star.fill")
                            .foregroundStyle(.yellow)
                            .fontWeight(.bold)
                        Spacer()
                        if let date = repo.updatedAt {
                            Text("Updated \(RelativeDateTimeFormatter().localizedString(for: date, relativeTo: .now))")
                                .foregroundStyle(.gray)
                        }
                    }
                    .font(.caption)
                }
                // Back
                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : (colorScheme == .dark ? .white : .black))
                        .imageScale(.large)
                        .accessibilityLabel(isFavorite ? "Unfavorite" : "Favorite")
                }
            }.padding(8)
                .background(colorScheme == .dark ? .black : .white)
                .cornerRadius(12)
                .padding(.horizontal, 8)
            
    }
}

#Preview {
    let fixedDate = Calendar.current.date(from: DateComponents(
        year: 2025, month: 8, day: 20, hour: 12, minute: 30
    ))!
    let fixedDate2 = Calendar.current.date(from: DateComponents(
        year: 2025, month: 8, day: 22, hour: 12, minute: 30
    ))!
        
    return VStack(spacing: 0) {
        RepoRow(
            repo: .init(
                id: 123,
                fullName: "TestRepoOwner/TestRepoName",
                description: "Test Description long enough to trigger truncation, but not too long.",
                stargazersCount: 123,
                ownerLogin: "OwnerLogin",
                htmlURL: URL(string: "https://example.com")!,
                updatedAt: fixedDate
            ),
            isFavorite: false,
            onToggleFavorite: { }
        )
        
        RepoRow(
            repo: .init(
                id: 123,
                fullName: "Owner/Name",
                description: "Test Description short.",
                stargazersCount: 12340,
                ownerLogin: "OwnerLogin",
                htmlURL: URL(string: "https://example.com")!,
                updatedAt: fixedDate2
            ),
            isFavorite: true,
            onToggleFavorite: { }
        )
    }
}
