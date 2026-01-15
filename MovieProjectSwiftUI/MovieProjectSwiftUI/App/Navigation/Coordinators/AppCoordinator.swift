//
//  AppCoordinator.swift
//  MovieProjectSwiftUI
//
//  Created by Çağatay Eğilmez on 14.01.2026.
//

import SwiftUI
import Combine

/// App-level coordinator that owns navigation/flow only.
///
/// Note: The current app target deploys to iOS 15.x, so we use `NavigationView` for now
/// (not `NavigationStack` / `NavigationPath`, which require iOS 16+).
final class AppCoordinator: ObservableObject, BaseCoordinator {
    enum Route: Hashable {
        case home
        // Future routes (e.g. movieDetail) will be added during feature implementation.
    }

    struct MovieDetailRoute: Hashable, Identifiable {
        var id: Int { movieId }
        let movieId: Int
        let title: String
    }

    @Published var movieDetailRoute: MovieDetailRoute? = nil

    func start() -> Route {
        .home
    }

    func navigateToMovieDetail(movieId: Int, title: String) {
        movieDetailRoute = MovieDetailRoute(movieId: movieId, title: title)
    }

    func clearMovieDetailRoute() {
        movieDetailRoute = nil
    }
    
    @ViewBuilder
    func makeMovieDetailView(movieId: Int, title: String) -> some View {
        // - TODO: Add movie detail view
        EmptyView()
    }
    
    func setMovieDetailRoute(_ route: MovieDetailRoute?) {
        movieDetailRoute = route
    }
}

/// Coordinator-owned root container.
struct AppCoordinatorRootView: View {
    @ObservedObject private var coordinator: AppCoordinator

    init(coordinator: AppCoordinator) {
        _coordinator = ObservedObject(wrappedValue: coordinator)
    }

    var body: some View {
        NavigationStack {
            HomeContainerView(coordinator: coordinator)
                .navigationDestination(item: $coordinator.movieDetailRoute) { route in
                    coordinator.makeMovieDetailView(movieId: route.movieId, title: route.title)
                }
        }
        .task {
            await NetworkingSanityCheck.run()
        }
    }
}

private struct HomeContainerView: View {
    @ObservedObject var coordinator: AppCoordinator
    @StateObject private var viewModel: HomeViewModel

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        let api = ServiceLayer()
        _viewModel = StateObject(
            wrappedValue: HomeViewModel(
                fetchNowPlaying: {
                    try await api.send(request: GetNowPlayingListRequest())
                },
                fetchUpcoming: { page in
                    try await api.send(request: GetUpcomingListRequest(page: page))
                },
                onNavigateToMovieDetail: { movieId, title in
                    coordinator.navigateToMovieDetail(movieId: movieId, title: title)
                }
            )
        )
    }

    var body: some View {
        HomeView(viewModel: viewModel)
    }
}

private struct MovieDetailPlaceholderView: View {
    let title: String
    let onDisappear: () -> Void

    var body: some View {
        Text(title.isEmpty ? "Movie Detail" : title)
            .onDisappear(perform: onDisappear)
    }
}


