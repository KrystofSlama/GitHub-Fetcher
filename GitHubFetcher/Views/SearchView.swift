import SwiftUI

struct SearchView: View {
    @Environment(\.colorScheme) private var colorScheme

    @Environment(\.modelContext) private var context

    @StateObject var vm: SearchViewModel
    let service: GitHubService
    init(vm: SearchViewModel, service: GitHubService) {
        _vm = StateObject(wrappedValue: vm)
        self.service = service
    }
    
    @State private var clearSearch: Bool = true
    @State private var searchActive: Bool = false
    
    var body: some View {
        NavigationStack {
            
            
            
            
            
            VStack {

                
                // Error
                if let err = vm.errorText {
                    Section { Text(err).foregroundStyle(.red) }
                }
                
                // MARK: -Results
                if searchActive {
                    if (clearSearch || vm.results.isEmpty) {
                        VStack(spacing: 0) {
                            HStack {
                                Text("Last Opened")
                                    .font(.title3)
                                Spacer()
                            }.padding(.leading)
                            
                            ScrollView {
                                ForEach(vm.recentOpened) { repo in
                                    NavigationLink {
                                        ContentView()
                                    } label: {
                                        RepoRow(
                                            repo: repo,
                                            isFavorite: vm.isFavorite(repo),
                                            onToggleFavorite: { vm.toggleFavorite(repo) }
                                        )
                                    }
                                    .simultaneousGesture(TapGesture().onEnded { vm.markOpened(repo) })
                                    .swipeActions {
                                        Button(vm.isFavorite(repo) ? "Unfavorite" : "Favorite") {
                                            vm.toggleFavorite(repo)
                                        }
                                        .tint(vm.isFavorite(repo) ? .gray : .yellow)
                                    }
                                }
                            }
                        }
                    } else {
                        // Searched
                        VStack(spacing: 0) {
                            HStack {
                                Text("Results")
                                    .font(.title3)
                                Spacer()
                            }.padding(.leading)
                            
                            ScrollView {
                                ForEach(vm.results) { repo in
                                    NavigationLink {
                                        ContentView()
                                    } label: {
                                        RepoRow(
                                            repo: repo,
                                            isFavorite: vm.isFavorite(repo),
                                            onToggleFavorite: { vm.toggleFavorite(repo) }
                                        )
                                    }
                                    .simultaneousGesture(TapGesture().onEnded { vm.markOpened(repo) })
                                    .swipeActions {
                                        Button(vm.isFavorite(repo) ? "Unfavorite" : "Favorite") {
                                            vm.toggleFavorite(repo)
                                        }
                                        .tint(vm.isFavorite(repo) ? .gray : .yellow)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    //Favorites
                    if !vm.favorites.isEmpty {
                        VStack(spacing: 0) {
                            HStack {
                                Text("Favorites")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .onAppear {
                                        print(vm.favorites)
                                    }
                                Spacer()
                            }.padding(.leading)
                            ScrollView {
                                ForEach(vm.favorites) { repo in
                                    NavigationLink {
                                        RepoDashboardView(fullName: repo.fullName, context: context, searchVM: vm, service: service)
                                    } label: {
                                        RepoRow(
                                            repo: repo,
                                            isFavorite: true,
                                            onToggleFavorite: { vm.toggleFavorite(repo) }
                                        )
                                    }
                                    .simultaneousGesture(TapGesture().onEnded { vm.markOpened(repo) })
                                    .swipeActions {
                                        Button("Unfavorite") { vm.toggleFavorite(repo) }.tint(.gray)
                                    }
                                }
                            }
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text("Type a query and press Search ↵")
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Search Repos")
            .toolbar {
                ToolbarItem {
                    NavigationLink(destination: SettingsView(service: service)) {
                        Image(systemName: "gear")
                    }.foregroundStyle(.black)
                }
            }
            .searchable(
                text: $vm.query,
                isPresented: $searchActive,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Type query, then press Search"
            )
            .onSubmit(of: .search) { Task { await vm.searchNow() } }
            .onChange(of: vm.query) { oldValue, newValue in
                if oldValue.isEmpty {
                    self.clearSearch = true
                } else {
                    self.clearSearch = false
                }
            }
            .background(Color(.systemGray6))
        }
    }
}

