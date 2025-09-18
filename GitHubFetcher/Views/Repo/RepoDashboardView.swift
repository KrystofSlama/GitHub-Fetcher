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
    @StateObject private var vm: RepoDashboardViewModel

    @ObservedObject var searchVM: SearchViewModel

    // Expandable lists
    @State private var isExpandedIssues: Bool = false

    init(fullName: String, context: ModelContext, searchVM: SearchViewModel, service: GitHubService) {
        _vm = StateObject(wrappedValue: RepoDashboardViewModel(
            fullName: fullName,
            context: context,
            service: service
        ))
        self.searchVM = searchVM
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

                        // MARK: -Issues, Commits
                        
                        
                        
                        
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .center) {
                                Text("Open Issues:")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(colorScheme == .light ? .black : .white)
                                
                                Button {
                                    isExpandedIssues.toggle()
                                } label : {
                                    HStack{
                                        Spacer()
                                        Image(systemName: isExpandedIssues ? "chevron.up" : "chevron.down")
                                            .fontWeight(.bold)
                                            .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))
                                            .foregroundStyle(colorScheme == .light ? .black : .white)
                                    }
                                }
                                }.padding(.horizontal, 8)
                                .padding(.vertical, 6)
                            
                            if isExpandedIssues {
                                VStack(spacing: 8) {
                                    ForEach(vm.issues) { issue in
                                        NavigationLink {
                                            RepoIssueView(
                                                viewModel: vm,
                                                repoName: r.fullName,
                                                issueNumber: issue.number
                                            )
                                        } label: {
                                            HStack(alignment: .center, spacing: 6) {
                                                Image(systemName: "circle.fill")
                                                    .resizable()
                                                    .frame(width: 7, height: 7)
                                                    .foregroundStyle(colorScheme == . light ? .black : .white)
                                                
                                                Text(issue.title)
                                                    .lineLimit(1)
                                                    .fontWeight(.semibold)
                                                    .foregroundStyle(colorScheme == . light ? .black : .white)
                                                
                                                Spacer()
                                                Text("#\(String(issue.number))")
                                                    .font(.callout)
                                                    .foregroundStyle(.gray)
                                            }.padding(.horizontal, 8)
                                        }
                                    }
                                }.padding(.bottom, 8)
                            }
                            
                        }.frame(maxWidth: .infinity, alignment: .leading)
                            .background(colorScheme == .dark ? .black : .white)
                            .cornerRadius(8)
                            .shadow(color: colorScheme == .dark ? .gray : .black.opacity(0.2), radius: colorScheme == .dark ? 0 : 3)
                            .padding(.top, 16)
                        
                        
                        
                        
                        
                        
                        
    

                        VStack(alignment: .leading, spacing: 0) {
                            Text("Recent Commits:")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.top, 6)
                            ForEach(vm.commits) { commit in
                                Link(commit.message, destination: commit.url)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 2)
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                            .background(colorScheme == .dark ? .black : .white)
                            .cornerRadius(8)
                            .shadow(color: colorScheme == .dark ? .gray : .black.opacity(0.2), radius: colorScheme == .dark ? 0 : 3)
                            .padding(.top, 16)

                        Spacer()
                        // MARK: -

                        HStack {
                            Spacer()
                            Text("Updated at: \(r.lastFetchedAt.formatted(date: .abbreviated, time: .shortened))")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                            Spacer()
                        }
                    }.padding(.horizontal, 8)
                } else if vm.isLoading {
                    ProgressView("Loading…")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 32)
                }
            }
            .refreshable { Task { await vm.refresh() } }
            
            if let message = vm.errorText {
                VStack {
                    Spacer()
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        Text(message)
                            .font(.callout)
                    }
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.red.opacity(colorScheme == .dark ? 0.15 : 0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.horizontal, 8)
                    .padding(.bottom, 12)
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
