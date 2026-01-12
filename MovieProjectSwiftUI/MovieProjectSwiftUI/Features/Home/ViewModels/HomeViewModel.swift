import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    enum ViewState: Equatable {
        case loading
        case empty
        case success
        case error(message: String)
    }

    // MARK: - Outputs (state)
    @Published private(set) var state: ViewState = .loading
    @Published private(set) var nowPlaying: [MovieListModel] = []
    @Published private(set) var upcoming: [MovieListModel] = []
    @Published var alertMessage: String? = nil

    // MARK: - Dependencies (no new abstraction; closures for testability)
    private let fetchNowPlaying: @Sendable () async throws -> MovieModel
    private let fetchUpcoming: @Sendable (_ page: Int) async throws -> MovieModel

    // MARK: - Internal
    private var currentPage: Int = 1
    private var initialLoadTask: Task<Void, Never>?
    private var isInitialLoaded: Bool = false

    /// Navigation intent handler (owned by Coordinator).
    private let onNavigateToMovieDetail: (_ movieId: Int, _ title: String) -> Void

    init(
        fetchNowPlaying: @escaping @Sendable () async throws -> MovieModel,
        fetchUpcoming: @escaping @Sendable (_ page: Int) async throws -> MovieModel,
        onNavigateToMovieDetail: @escaping (_ movieId: Int, _ title: String) -> Void
    ) {
        self.fetchNowPlaying = fetchNowPlaying
        self.fetchUpcoming = fetchUpcoming
        self.onNavigateToMovieDetail = onNavigateToMovieDetail
    }

    deinit {
        initialLoadTask?.cancel()
    }

    // MARK: - Lifecycle
    func onAppear() {
        // When the app is launched as a test host, avoid starting real network calls from view lifecycle.
        // Unit tests call `loadInitial()` directly with stubbed closures.
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return
        }
        guard !isInitialLoaded else { return }
        isInitialLoaded = true

        initialLoadTask?.cancel()
        initialLoadTask = Task { [weak self] in
            guard let self else { return }
            await self.loadInitial()
        }
    }

    // MARK: - API sequencing (UIKit parity)
    /// UIKit parity:
    /// - Start "loading" (but UIKit shows no loader UI because loader is commented out).
    /// - Fetch now playing, then upcoming page `currentPage` (initially 1).
    /// - Only after upcoming returns successfully does the UI refresh.
    func loadInitial() async {
        state = .loading

        do {
            let nowPlayingResponse = try await fetchNowPlaying()
            nowPlaying = nowPlayingResponse.results

            let upcomingResponse = try await fetchUpcoming(currentPage)
            upcoming.append(contentsOf: upcomingResponse.results)

            recomputeStateAfterDataChange()
        } catch {
            // UIKit shows an alert and stops the (non-visible) loader.
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            state = .error(message: message)
            alertMessage = message
        }
    }

    /// UIKit parity:
    /// - Pull-to-refresh sets `currentPage = 0` and fetches upcoming for page 0
    /// - Does NOT clear the existing upcoming list; it appends.
    func refresh() async {
        currentPage = 0
        do {
            let upcomingResponse = try await fetchUpcoming(currentPage)
            upcoming.append(contentsOf: upcomingResponse.results)
            recomputeStateAfterDataChange()
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            alertMessage = message
            // Keep existing UI (UIKit doesn't clear UI on pagination/refresh error).
        }
    }

    /// UIKit parity:
    /// - When reaching the bottom, increments `currentPage` and fetches upcoming again, appending results.
    /// - No in-flight guard exists in UIKit; repeated triggers can issue multiple requests.
    func loadMore() async {
        currentPage += 1
        do {
            let upcomingResponse = try await fetchUpcoming(currentPage)
            upcoming.append(contentsOf: upcomingResponse.results)
            recomputeStateAfterDataChange()
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            alertMessage = message
            // Keep current UI on error.
        }
    }

    // MARK: - User actions
    func didSelectNowPlaying(movieId: Int) {
        // UIKit: derives title by filtering nowPlaying by id and force-indexing [0]
        // We avoid crashing by guarding, but we won't navigate if not found.
        guard let title = nowPlaying.first(where: { $0.id == movieId })?.title else { return }
        onNavigateToMovieDetail(movieId, title)
    }

    func didSelectUpcoming(movie: MovieListModel) {
        onNavigateToMovieDetail(movie.id, movie.title)
    }

    // MARK: - Helpers
    private func recomputeStateAfterDataChange() {
        if nowPlaying.isEmpty, upcoming.isEmpty {
            state = .empty
        } else {
            state = .success
        }
    }
}


