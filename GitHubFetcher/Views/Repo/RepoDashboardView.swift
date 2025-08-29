//
//  RepoDashboardView.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 22.08.2025.
//

import SwiftUI
import SwiftData

struct RepoDashboardView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var vm: RepooDashboardViewModel

    @ObservedObject var searchVM: SearchViewModel

    init(fullName: String, token: String, context: ModelContext, searchVM: SearchViewModel) {
        let service = GitHubService(token: token)
        _vm = StateObject(wrappedValue: RepooDashboardViewModel(
            fullName: fullName,
            context: context,
            service: service
        ))
        self.searchVM = searchVM


        // Search
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView {
                if let r = vm.repo {
                    let summary = RepoSummary(
                        id: r.databaseId,
                        fullName: r.fullName,
                        description: r.rDescription,
                        stargazersCount: r.stars,
                        ownerLogin: r.owner,
                        htmlURL: r.htmlURL,
                        updatedAt: nil
                    )
                    VStack {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(r.name)
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                HStack(alignment: .bottom) {
                                    Text("By:")
                                    Text(r.owner)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                            }
                            Spacer()
                            Button(action: { searchVM.toggleFavorite(summary) }) {
                                Image(systemName: searchVM.isFavorite(summary) ? "heart.fill" : "heart")
                                    .foregroundStyle(.black)
                            }
                        }
                        // MARK: -Dashboard
                        VStack(spacing: 16) {
                            // First Row
                            HStack(spacing: 16) {
                                // Stars
                                HStack(alignment: .center, spacing: 2) {
                                    Spacer()
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                    Text("\(r.stars)")
                                        .font(.largeTitle)
                                        .fontWeight(.medium)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                    
                                    if (vm.delta?.stars ?? 0) > 0 {
                                        VStack(spacing: 0) {
                                            Image(systemName: "arrowtriangle.up.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.green)
                                            Image(systemName: "arrowtriangle.down.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.red)
                                                .opacity(0.2)
                                            
                                        }
                                    } else if (vm.delta?.stars ?? 0) < 0 {
                                        VStack(spacing: 0) {
                                            Image(systemName: "arrowtriangle.up.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.green)
                                                .opacity(0.2)
                                            Image(systemName: "arrowtriangle.down.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.red)
                                        }
                                    } else {
                                        VStack(spacing: 0) {
                                            Image(systemName: "arrowtriangle.up.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.green)
                                                .opacity(0.2)
                                            Image(systemName: "arrowtriangle.down.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.red)
                                                .opacity(0.2)
                                            
                                        }
                                    }
                                    if (vm.delta?.stars ?? 0) > 0 {
                                        Text("+\(vm.delta?.stars ?? 0)")
                                            .font(.footnote)
                                            .foregroundStyle(.green)
                                    } else if (vm.delta?.stars ?? 0) < 0 {
                                        Text("\(vm.delta?.stars ?? 0)")
                                            .font(.footnote)
                                            .foregroundStyle(.red)
                                    } else {
                                        Text("\(vm.delta?.stars ?? 0)")
                                            .font(.footnote)
                                            .foregroundStyle(.black)
                                            .opacity(0.2)
                                    }
                                    Spacer()
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 3)
                                
                                // Watchers
                                HStack(spacing: 2) {
                                    Spacer()
                                    Image(systemName: "eye")
                                        .foregroundStyle(.black)
                                    Text("\(r.watchers)")
                                        .font(.largeTitle)
                                        .fontWeight(.medium)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                    
                                    if (vm.delta?.watchers ?? 0) > 0 {
                                        VStack(spacing: 0) {
                                            Image(systemName: "arrowtriangle.up.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.green)
                                            Image(systemName: "arrowtriangle.down.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.red)
                                                .opacity(0.2)
                                            
                                        }
                                    } else if (vm.delta?.watchers ?? 0) < 0 {
                                        VStack(spacing: 0) {
                                            Image(systemName: "arrowtriangle.up.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.green)
                                                .opacity(0.2)
                                            Image(systemName: "arrowtriangle.down.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.red)
                                        }
                                    } else {
                                        VStack(spacing: 0) {
                                            Image(systemName: "arrowtriangle.up.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.green)
                                                .opacity(0.2)
                                            Image(systemName: "arrowtriangle.down.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.red)
                                                .opacity(0.2)
                                            
                                        }
                                    }
                                    if (vm.delta?.watchers ?? 0) > 0 {
                                        Text("+\(vm.delta?.watchers ?? 0342)")
                                            .font(.footnote)
                                            .foregroundStyle(.green)
                                    } else if (vm.delta?.watchers ?? 0) < 0 {
                                        Text("\(vm.delta?.watchers ?? 0234)")
                                            .font(.footnote)
                                            .foregroundStyle(.red)
                                    } else {
                                        Text("\(vm.delta?.watchers ?? 0123)")
                                            .font(.footnote)
                                            .foregroundStyle(.black)
                                            .opacity(0.2)
                                    }
                                    Spacer()
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 3)
                                
                            }.frame(height: 80)
                            
                            // Second Row
                            HStack(spacing: 16) {
                                // Open Issues
                                HStack(alignment: .center, spacing: 2) {
                                    Spacer()
                                    Image(systemName: "exclamationmark.circle")
                                        .foregroundStyle(.black)
                                    Text("\(r.openIssues)")
                                        .font(.largeTitle)
                                        .fontWeight(.medium)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                    
                                    if (vm.delta?.openIssues ?? 0) > 0 {
                                        VStack(spacing: 0) {
                                            Image(systemName: "arrowtriangle.up.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.green)
                                            Image(systemName: "arrowtriangle.down.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.red)
                                                .opacity(0.2)
                                            
                                        }
                                    } else if (vm.delta?.openIssues ?? 0) < 0 {
                                        VStack(spacing: 0) {
                                            Image(systemName: "arrowtriangle.up.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.green)
                                                .opacity(0.2)
                                            Image(systemName: "arrowtriangle.down.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.red)
                                        }
                                    } else {
                                        VStack(spacing: 0) {
                                            Image(systemName: "arrowtriangle.up.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.green)
                                                .opacity(0.2)
                                            Image(systemName: "arrowtriangle.down.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.red)
                                                .opacity(0.2)
                                            
                                        }
                                    }
                                    if (vm.delta?.openIssues ?? 0) > 0 {
                                        Text("+\(vm.delta?.openIssues ?? 0342)")
                                            .font(.footnote)
                                            .foregroundStyle(.green)
                                    } else if (vm.delta?.openIssues ?? 0) < 0 {
                                        Text("\(vm.delta?.openIssues ?? 0234)")
                                            .font(.footnote)
                                            .foregroundStyle(.red)
                                    } else {
                                        Text("\(vm.delta?.openIssues ?? 0123)")
                                            .font(.footnote)
                                            .foregroundStyle(.black)
                                            .opacity(0.2)
                                    }
                                    Spacer()
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 3)
                                
                                // Open PR
                                HStack(spacing: 2) {
                                    Spacer()
                                    Image(systemName: "arrow.trianglehead.pull")
                                        .foregroundStyle(.black)
                                    Text("\(r.openPRs)")
                                        .font(.largeTitle)
                                        .fontWeight(.medium)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                    
                                    if (vm.delta?.openPRs ?? 0) > 0 {
                                        VStack(spacing: 0) {
                                            Image(systemName: "arrowtriangle.up.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.green)
                                            Image(systemName: "arrowtriangle.down.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.red)
                                                .opacity(0.2)
                                            
                                        }
                                    } else if (vm.delta?.openPRs ?? 0) < 0 {
                                        VStack(spacing: 0) {
                                            Image(systemName: "arrowtriangle.up.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.green)
                                                .opacity(0.2)
                                            Image(systemName: "arrowtriangle.down.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.red)
                                        }
                                    } else {
                                        VStack(spacing: 0) {
                                            Image(systemName: "arrowtriangle.up.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.green)
                                                .opacity(0.2)
                                            Image(systemName: "arrowtriangle.down.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.red)
                                                .opacity(0.2)
                                            
                                        }
                                    }
                                    if (vm.delta?.openPRs ?? 0) > 0 {
                                        Text("+\(vm.delta?.openPRs ?? 0)")
                                            .font(.footnote)
                                            .foregroundStyle(.green)
                                    } else if (vm.delta?.openPRs ?? 0) < 0 {
                                        Text("\(vm.delta?.openPRs ?? 0)")
                                            .font(.footnote)
                                            .foregroundStyle(.red)
                                    } else {
                                        Text("\(vm.delta?.openPRs ?? 0)")
                                            .font(.footnote)
                                            .foregroundStyle(.black)
                                            .opacity(0.2)
                                    }
                                    Spacer()
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 3)
                                
                            }.frame(height: 80)
                        }
                        // MARK: -Description
                        Text("\(r.rDescription)")
                        Spacer()
                        // MARK: -Updated
                        HStack {
                            Text("Updated at: \(r.lastFetchedAt.formatted(date: .abbreviated, time: .shortened))")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                } else {
                    Text("Loading...")
                }
            }
            .refreshable { await vm.refresh() }
        }
        .padding()
        .task { await vm.load() }      // pull-to-refresh
        .toolbar {
            Button {
                
            } label: {
                if vm.isLoading {
                    
                }
            }
        }
    }
}
