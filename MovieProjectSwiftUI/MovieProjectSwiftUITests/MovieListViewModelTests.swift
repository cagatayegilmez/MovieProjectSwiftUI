import XCTest
@testable import MovieProjectSwiftUI

@MainActor
final class MovieListViewModelTests: XCTestCase {
    private func decodeMovieModel(_ json: String) throws -> MovieModel {
        try JSONDecoder().decode(MovieModel.self, from: Data(json.utf8))
    }

    func test_loadInitial_success_setsSuccessAndLoadsPage1() async {
        var requestedPages: [Int] = []
        let page1 = try! decodeMovieModel("""
        { "results": [ { "id": 1, "backdrop_path": "/a.jpg", "title": "P1", "vote_average": 7.0, "overview": "O", "release_date": "2020-01-01" } ] }
        """)

        let viewModel = MovieListViewModel(fetchPage: { page in
            requestedPages.append(page)
            return page1
        })

        await viewModel.loadInitial()

        XCTAssertEqual(requestedPages, [1])
        XCTAssertEqual(viewModel.state, .success)
        XCTAssertEqual(viewModel.movies.count, 1)
    }

    func test_loadMore_incrementsPageAndAppends() async {
        var requestedPages: [Int] = []
        let page1 = try! decodeMovieModel("""
        { "results": [ { "id": 1, "backdrop_path": "/a.jpg", "title": "P1", "vote_average": 7.0, "overview": "O", "release_date": "2020-01-01" } ] }
        """)
        let page2 = try! decodeMovieModel("""
        { "results": [ { "id": 2, "backdrop_path": "/b.jpg", "title": "P2", "vote_average": 7.0, "overview": "O2", "release_date": "2020-01-02" } ] }
        """)

        let viewModel = MovieListViewModel(fetchPage: { page in
            requestedPages.append(page)
            return page == 1 ? page1 : page2
        })

        await viewModel.loadInitial()
        await viewModel.loadMore()

        XCTAssertEqual(requestedPages, [1, 2])
        XCTAssertEqual(viewModel.movies.map(\.id), [1, 2])
    }

    func test_refresh_resetsToPage0_andReplacesData() async {
        var requestedPages: [Int] = []
        let page1 = try! decodeMovieModel("""
        { "results": [ { "id": 1, "backdrop_path": "/a.jpg", "title": "P1", "vote_average": 7.0, "overview": "O", "release_date": "2020-01-01" } ] }
        """)
        let page0 = try! decodeMovieModel("""
        { "results": [ { "id": 10, "backdrop_path": "/z.jpg", "title": "P0", "vote_average": 7.0, "overview": "O0", "release_date": "2020-01-01" } ] }
        """)

        let viewModel = MovieListViewModel(fetchPage: { page in
            requestedPages.append(page)
            return page == 0 ? page0 : page1
        })

        await viewModel.loadInitial()
        await viewModel.refresh()

        XCTAssertEqual(requestedPages, [1, 0])
        XCTAssertEqual(viewModel.movies.map(\.id), [10])
    }
}


