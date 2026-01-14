//
//  HomeView.swift
//  MovieProjectSwiftUI
//
//  Created by Çağatay Eğilmez on 14.01.2026.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            platformBackgroundGray.ignoresSafeArea()
            content
                .onAppear {
                    viewModel.onAppear()
                }
                .alert(isPresented: Binding(
                    get: { viewModel.alertMessage != nil },
                    set: { if !$0 { viewModel.alertMessage = nil } }
                )) {
                    Alert(
                        title: Text(""),
                        message: Text(viewModel.alertMessage ?? ""),
                        dismissButton: .cancel(Text("İptal"))
                    )
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading, .empty, .error:
            // TODO: Loading View
            homeContent(nowPlaying: viewModel.nowPlaying, upcoming: viewModel.upcoming)
        case .success:
            homeContent(nowPlaying: viewModel.nowPlaying, upcoming: viewModel.upcoming)
        }
    }

    private func homeContent(nowPlaying: [MovieListModel], upcoming: [MovieListModel]) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                nowPlayingCarousel(nowPlaying)
                    .frame(height: carouselHeight)

                VStack(spacing: 0) {
                    ForEach(upcoming, id: \.id) { movie in
                        UpcomingRow(movie: movie)
                            .onTapGesture {
                                viewModel.didSelectUpcoming(movie: movie)
                            }
                            .task {
                                if movie.id == upcoming.last?.id {
                                    await viewModel.loadMore()
                                }
                            }
                    }
                }
                .padding(.top, 12)
            }
        }
        .background(.white)
        .refreshable {
            await viewModel.refresh()
        }
    }

    private func nowPlayingCarousel(_ movies: [MovieListModel]) -> some View {
        TabView {
            ForEach(movies, id: \.id) { movie in
                CarouselCard(movie: movie)
                    .onTapGesture {
                        viewModel.didSelectNowPlaying(movieId: movie.id)
                    }
            }
        }
        #if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        #endif
    }
}

private struct CarouselCard: View {
    let movie: MovieListModel

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: movie.imageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    platformPlaceholder
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    platformPlaceholder
                @unknown default:
                    platformPlaceholder
                }
            }
            .clipped()

            LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.4), Color.black.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("\(movie.title) (\(movie.releaseDateYear))")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text(movie.overview)
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }
}

private struct UpcomingRow: View {
    let movie: MovieListModel

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: movie.imageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    platformPlaceholder
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    platformPlaceholder
                @unknown default:
                    platformPlaceholder
                }
            }
            .frame(width: 104, height: 104)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "#2B2D42"))
                    .lineLimit(2)

                Text(movie.overview)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#8D99AE"))
                    .lineLimit(2)

                HStack {
                    Spacer()
                    Text(movie.releaseDateDotted)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#8D99AE"))
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "#8D99AE"))
                .padding(.trailing, 6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
    }
}

private extension MovieListModel {
    var releaseDateYear: String {
        String(Calendar.current.component(.year, from: releaseDate))
    }

    var releaseDateDotted: String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: releaseDate)
        let month = calendar.component(.month, from: releaseDate)
        let year = calendar.component(.year, from: releaseDate)
        return "\(day).\(month).\(year)"
    }
}

private extension Color {
    init(hex: String) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") { cString.removeFirst() }
        guard cString.count == 6 else {
            self = Color(.systemGray)
            return
        }
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        self = Color(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}

private var carouselHeight: CGFloat {
    #if os(iOS)
    UIScreen.main.bounds.height / 2.7
    #else
    280
    #endif
}

private var platformBackgroundGray: Color {
    #if os(iOS)
    Color(.systemGray)
    #else
    Color.gray
    #endif
}

private var platformPlaceholder: Color {
    #if os(iOS)
    Color(.systemGray4)
    #else
    Color.gray.opacity(0.3)
    #endif
}


