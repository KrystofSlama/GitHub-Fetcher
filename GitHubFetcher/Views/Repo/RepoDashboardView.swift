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
    @Environment(\.colorScheme) var colorScheme
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
        VStack {
            ScrollView {
                if let r = vm.repo {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(r.name)
                                    .font(.system(size: 40))
                                    .fontWeight(.heavy)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .padding(.vertical, -5)
                                
                                HStack(alignment: .bottom, spacing: 0) {
                                    Text("By:  ")
                                        .font(.title3)
                                    Text(r.owner)
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .padding(.bottom, -4)
                                }
                            }
                            Spacer()
                        }.padding(.bottom, 16)
                        // MARK: -Dashboard
                        VStack(spacing: 16) {
                            // First Row
                            HStack(spacing: 16) {
                                // Stars
                                HStack(alignment: .center, spacing: 2) {
                                    Spacer()
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                        .fontWeight(.semibold)
                                        .font(.title3)
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
                                    .background(colorScheme == .dark ? .black : .white)
                                    .cornerRadius(8)
                                    .shadow(color: colorScheme == .dark ? Color(.darkGray).opacity(0.2) : .gray.opacity(0.8), radius: 3)
                                
                                // Watchers
                                HStack(spacing: 2) {
                                    Spacer()
                                    Image(systemName: "eye")
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        .fontWeight(.semibold)
                                        .font(.title3)
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
                                        Text("+\(vm.delta?.watchers ?? 0)")
                                            .font(.footnote)
                                            .foregroundStyle(.green)
                                    } else if (vm.delta?.watchers ?? 0) < 0 {
                                        Text("\(vm.delta?.watchers ?? 0)")
                                            .font(.footnote)
                                            .foregroundStyle(.red)
                                    } else {
                                        Text("\(vm.delta?.watchers ?? 0)")
                                            .font(.footnote)
                                            .foregroundStyle(.black)
                                            .opacity(0.2)
                                    }
                                    Spacer()
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(colorScheme == .dark ? .black : .white)
                                    .cornerRadius(8)
                                    .shadow(color: colorScheme == .dark ? Color(.darkGray).opacity(0.2) : .gray.opacity(0.8), radius: 3)
                                
                            }.frame(height: 80)
                            
                            // Second Row
                            HStack(spacing: 16) {
                                // Open Issues
                                HStack(alignment: .center, spacing: 2) {
                                    Spacer()
                                    Image(systemName: "exclamationmark.circle")
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        .fontWeight(.semibold)
                                        .font(.title3)
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
                                        Text("+\(vm.delta?.openIssues ?? 0)")
                                            .font(.footnote)
                                            .foregroundStyle(.green)
                                    } else if (vm.delta?.openIssues ?? 0) < 0 {
                                        Text("\(vm.delta?.openIssues ?? 0)")
                                            .font(.footnote)
                                            .foregroundStyle(.red)
                                    } else {
                                        Text("\(vm.delta?.openIssues ?? 0)")
                                            .font(.footnote)
                                            .foregroundStyle(.black)
                                            .opacity(0.2)
                                    }
                                    Spacer()
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(colorScheme == .dark ? .black : .white)
                                    .cornerRadius(8)
                                    .shadow(color: colorScheme == .dark ? Color(.darkGray).opacity(0.2) : .gray.opacity(0.8), radius: 3)
                                
                                // Open PR
                                HStack(spacing: 2) {
                                    Spacer()
                                    Image(systemName: "arrow.trianglehead.pull")
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        .fontWeight(.semibold)
                                        .font(.title3)
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
                                    .background(colorScheme == .dark ? .black : .white)
                                    .cornerRadius(8)
                                    .shadow(color: colorScheme == .dark ? Color(.darkGray).opacity(0.2) : .gray.opacity(0.8), radius: 3)
                                
                            }.frame(height: 80)
                        }.padding(.horizontal, 10)
                        // MARK: -Description
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Description:")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.top, 6)
                            Text("\(r.rDescription)")
                                .padding(.horizontal, 12)
                                .padding(.bottom, 6)
                        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            .background(colorScheme == .dark ? .black : .white)
                            .cornerRadius(8)
                            .shadow(color: colorScheme == .dark ? .gray : .black.opacity(0.2), radius: colorScheme == .dark ? 0 : 3)
                            .padding(.top, 16)
                            
                        
                        Spacer()
                        // MARK: -
                        
                    }.padding(.horizontal, 8)
                } else {
                    Text("Loading...")
                }
            }
            .refreshable { Task { await vm.refresh() } }
            
            Spacer()
            // MARK: -Updated
            if let r = vm.repo {
                HStack {
                    Spacer()
                    Text("Updated at: \(r.lastFetchedAt.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    Spacer()
                }
            }
            
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color(.systemGray6))
        .task { await vm.load() }
        .toolbar {
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
                Button(action: { searchVM.toggleFavorite(summary) }) {
                    Image(systemName: searchVM.isFavorite(summary) ? "heart.fill" : "heart")
                        .foregroundStyle(searchVM.isFavorite(summary) ? .red : .black)
                }
            }
        }
    }
}
