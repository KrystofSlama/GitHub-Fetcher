import SwiftData

struct AppContainer {
    let modelContainer: ModelContainer
    let github: GitHubService
    let favorites: FavoritesStore

    static func make(token: String? = nil) -> AppContainer {
        // persistent SwiftData container (on-disk)
        let mc = try! ModelContainer(for: TrackedRepo.self)

        let github = GitHubService(token: token)
        let favorites = FavoritesStore()   // <-- no-arg init

        return AppContainer(modelContainer: mc, github: github, favorites: favorites)
    }
}
