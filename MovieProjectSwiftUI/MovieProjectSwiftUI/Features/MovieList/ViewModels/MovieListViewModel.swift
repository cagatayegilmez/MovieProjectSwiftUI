import Combine
import Foundation

@MainActor
final class MovieListViewModel: ObservableObject {
    enum ViewState: Equatable {
        case loading
        case empty
        case success
        case error(message: String)
    }

    @Published private(set) var state: ViewState = .loading
    @Published private(set) var movies: [MovieListModel] = []
    @Published var alertMessage: String? = nil

    private let fetchPage: @Sendable (_ page: Int) async throws -> MovieModel

    private var currentPage: Int = 1
    private var loadTask: Task<Void, Never>?
    private var isInitialLoaded = false

    init(fetchPage: @escaping @Sendable (_ page: Int) async throws -> MovieModel) {
        self.fetchPage = fetchPage
    }

    deinit {
        loadTask?.cancel()
    }

    func onAppear() {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return
        }
        guard !isInitialLoaded else { return }
        isInitialLoaded = true

        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            await self.loadInitial()
        }
    }

    func loadInitial() async {
        state = .loading
        currentPage = 1
        movies = []

        do {
            let response = try await fetchPage(currentPage)
            movies = response.results
            recomputeState()
        } catch {
            setError(error)
        }
    }

    func refresh() async {
        currentPage = 0
        do {
            let response = try await fetchPage(currentPage)
            movies = response.results
            recomputeState()
        } catch {
            alertMessage = localizedMessage(for: error)
        }
    }

    func loadMore() async {
        currentPage += 1
        do {
            let response = try await fetchPage(currentPage)
            movies.append(contentsOf: response.results)
            recomputeState()
        } catch {
            alertMessage = localizedMessage(for: error)
        }
    }

    private func recomputeState() {
        state = movies.isEmpty ? .empty : .success
    }

    private func setError(_ error: Error) {
        let message = localizedMessage(for: error)
        state = .error(message: message)
        alertMessage = message
    }

    private func localizedMessage(for error: Error) -> String {
        (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
    }
}


