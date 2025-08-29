//
//  RepoO2.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 25.08.2025.
//


/*
import SwiftUI

struct RepoDashboarddView: View {
    @StateObject private var vm: DashboardViewModel

    let repo: RepoSummary
    
    init(repo: RepoSummary, token: String? = "<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>") {
        self.repo = repo
        // Parse "owner/name" from the RepoSummary you already have
        let (owner, name) = repo.ownerAndName ?? ("", "")
        // Build the service & VM
        let api = GitHubService(token: token)
        _vm = StateObject(wrappedValue: DashboardViewModel(owner: owner, name: name, api: api))
    }

    var body: some View {
        VStack {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(repo.ownerAndName?.1 ?? "")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    HStack(alignment: .bottom) {
                        Text("By:")
                        Text(repo.ownerAndName?.1 ?? "")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                Spacer()
            }
            // Dashboard
            VStack(spacing: 16) {
                // First Row
                HStack(spacing: 16) {
                    // Stars
                    HStack(alignment: .center, spacing: 2) {
                        Spacer()
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text("\(vm.detail?.stars ?? 0)")
                            .font(.largeTitle)
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        VStack(spacing: 0) {
                            Image(systemName: "arrowtriangle.up.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.caption2)
                                .foregroundStyle(.red)
                                .opacity(0.2)
                                
                        }
                        Text("+5")
                            .font(.footnote)
                            .foregroundStyle(.green)
                        Spacer()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.white)
                        .cornerRadius(8)
                        .shadow(radius: 3)
                        
                    // Issues
                    HStack(spacing: 2) {
                        Spacer()
                        Image(systemName: "exclamationmark.circle")
                            .foregroundStyle(.black)
                        Text("\(vm.detail?.openIssuesCount ?? 0)")
                            .font(.largeTitle)
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        VStack(spacing: 0) {
                            Image(systemName: "arrowtriangle.up.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                                .opacity(0.2)
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.caption2)
                                .foregroundStyle(.red)
                                .opacity(1)
                                
                        }
                        Text("-5")
                            .font(.footnote)
                            .foregroundStyle(.red)
                        Spacer()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.white)
                        .cornerRadius(8)
                        .shadow(radius: 3)
                        
                }.frame(height: 80)
                // Second Row
                HStack(spacing: 16) {
                    // Stars
                    HStack(alignment: .center, spacing: 2) {
                        Spacer()
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text("\(vm.repoDetail?.starsCount ?? 0)")
                            .font(.largeTitle)
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        
                        
                        
                        if vm.repoDetail?.openIssuesCount ?? 0 > 0 {
                            VStack(spacing: 0) {
                                Image(systemName: "arrowtriangle.up.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.green)
                                Image(systemName: "arrowtriangle.down.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                                    .opacity(0.2)
                                    
                            }
                        } else if vm.repoDetail?.openIssuesCount ?? 0 < 0 {
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
                        if vm.repoDetail?.openIssuesCount ?? 0 > 0 {
                            Text("+\(vm.repoDetail?.openIssuesCount ?? 0)")
                                .font(.footnote)
                                .foregroundStyle(.green)
                        } else if vm.repoDetail?.openIssuesCount ?? 0 < 0 {
                            Text("\(vm.repoDetail?.openIssuesCount ?? 0)")
                                .font(.footnote)
                                .foregroundStyle(.red)
                        } else {
                            Text("\(vm.repoDetail?.openIssuesCount ?? 0)")
                                .font(.footnote)
                                .foregroundStyle(.black)
                                .opacity(0.2)
                        }
                        Spacer()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.white)
                        .cornerRadius(8)
                        .shadow(radius: 3)
                        
                    // Issues
                    HStack(spacing: 2) {
                        Spacer()
                        Image(systemName: "exclamationmark.circle")
                            .foregroundStyle(.black)
                        Text("\(vm.repoDetail?.openIssuesCount ?? 0)")
                            .font(.largeTitle)
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        VStack(spacing: 0) {
                            Image(systemName: "arrowtriangle.up.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                                .opacity(0.2)
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.caption2)
                                .foregroundStyle(.red)
                                .opacity(1)
                                
                        }
                        Text("-5")
                            .font(.footnote)
                            .foregroundStyle(.red)
                        Spacer()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.white)
                        .cornerRadius(8)
                        .shadow(radius: 3)
                        
                }.frame(height: 80)
            }
            Spacer()
            
            Button("Refresh") {
                Task {
                    await vm.load()
                }
            }
            Button("Refresh2") {
                Task {
                    await vm.loadNew(repoName: repo.fullName)
                }
            }
            Button("Refresh3") {
                Task {
                    await vm.loadNew(repoName: repo.fullName)
                }
            }
        }.padding()
        
        
        if let repo = vm.repoDetail {
            Link("Open on GitHub", destination: repo.htmlURL)
                .font(.callout)
        }
        
        
        VStack(alignment: .leading, spacing: 12) {
            if let d = vm.detail {
                
                HStack(spacing: 16) {
                    Label("\(d.stars)", systemImage: "star.fill")
                    Label("\(d.openIssuesCount)", systemImage: "exclamationmark.circle")
                }
                Link("Open on GitHub", destination: d.summary.htmlURL)
                    .font(.callout)
            } else if vm.isLoading {
                ProgressView("Loading…")
            } else if let err = vm.errorText {
                Text(err).foregroundStyle(.red)
            }
            Spacer()
        }
        .padding()
        //.task { await vm.load() }      // fetch on appear
        //.refreshable { await vm.load() } // optional pull-to-refresh
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
    }
}
*/
