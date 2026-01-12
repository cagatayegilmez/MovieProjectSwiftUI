import XCTest
@testable import MovieProjectSwiftUI

@MainActor
final class HomeViewModelTests: XCTestCase {
    private func decodeMovieModel(_ json: String) throws -> MovieModel {
        try JSONDecoder().decode(MovieModel.self, from: Data(json.utf8))
    }

    func test_loadInitial_success_setsSuccessStateAndPublishesData() async {
        let nowPlaying: MovieModel
        let upcoming: MovieModel
        do {
            nowPlaying = try decodeMovieModel("""
            {
              "results": [
                {
                  "id": 1,
                  "backdrop_path": "/a.jpg",
                  "title": "Now Playing",
                  "vote_average": 7.1,
                  "overview": "Overview",
                  "release_date": "2020-01-02"
                }
              ]
            }
            """)
            upcoming = try decodeMovieModel("""
            {
              "results": [
                {
                  "id": 2,
                  "backdrop_path": "/b.jpg",
                  "title": "Upcoming",
                  "vote_average": 6.5,
                  "overview": "Overview 2",
                  "release_date": "2021-02-03"
                }
              ]
            }
            """)
        } catch {
            XCTFail("Failed to decode fixture JSON: \(error)")
            return
        }

        let viewModel = HomeViewModel(
            fetchNowPlaying: { nowPlaying },
            fetchUpcoming: { _ in upcoming },
            onNavigateToMovieDetail: { _, _ in }
        )

        await viewModel.loadInitial()

        XCTAssertEqual(viewModel.state, .success)
        XCTAssertEqual(viewModel.nowPlaying.count, 1)
        XCTAssertEqual(viewModel.upcoming.count, 1)
        XCTAssertNil(viewModel.alertMessage)
    }

    func test_loadInitial_error_setsErrorStateAndAlertMessage() async {
        struct TestError: LocalizedError {
            var errorDescription: String? { "Something went wrong." }
        }

        let viewModel = HomeViewModel(
            fetchNowPlaying: { throw TestError() },
            fetchUpcoming: { _ in MovieModel(results: []) },
            onNavigateToMovieDetail: { _, _ in }
        )

        await viewModel.loadInitial()

        XCTAssertEqual(viewModel.state, .error(message: "Something went wrong."))
        XCTAssertEqual(viewModel.alertMessage, "Something went wrong.")
        XCTAssertTrue(viewModel.nowPlaying.isEmpty)
        XCTAssertTrue(viewModel.upcoming.isEmpty)
    }
}


