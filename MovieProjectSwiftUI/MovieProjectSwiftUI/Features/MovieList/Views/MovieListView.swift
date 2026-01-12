import SwiftUI

struct MovieListView: View {
    @ObservedObject private var viewModel: MovieListViewModel

    init(viewModel: MovieListViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("Movies")
            .onAppear { viewModel.onAppear() }
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

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading, .empty, .error:
            // No loader/empty UI by design; show list container anyway.
            listView
        case .success:
            listView
        }
    }

    private var listView: some View {
        List {
            ForEach(viewModel.movies, id: \.id) { movie in
                MovieListRow(movie: movie)
                    .task {
                        if movie.id == viewModel.movies.last?.id {
                            await viewModel.loadMore()
                        }
                    }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
    }
}

private struct MovieListRow: View {
    let movie: MovieListModel

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: movie.imageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    placeholder
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)

                Text(movie.overview)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }

    private var placeholder: Color {
        #if os(iOS)
        Color(.systemGray5)
        #else
        Color.gray.opacity(0.3)
        #endif
    }
}

#Preview {
    MovieListView(
        viewModel: MovieListViewModel(fetchPage: { _ in MovieModel(results: []) })
    )
}


