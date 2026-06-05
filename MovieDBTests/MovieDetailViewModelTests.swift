//
//  MovieDetailViewModelTests.swift
//  MovieDBTests
//
//  Created by Natalia Tatarinteva on 04.06.26.
//

import Combine
import XCTest
@testable import MovieDB

@MainActor
final class MovieDetailViewModelTests: XCTestCase {

    private var repository: FakeMoviesRepository!
    private var sut: MovieDetailViewModel!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        repository = FakeMoviesRepository()
        sut = MovieDetailViewModel(movieID: 1, repository: repository)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        repository = nil
    }

    // MARK: - Loading

    func testInitialState_isLoading() {
        guard case .loading = sut.state else {
            return XCTFail("Expected loading state")
        }
    }

    func testLoad_success_setsLoadedState() async {
        let movie = Movie.stub(title: "Inception")
        repository.movieDetailResult = .success(movie)

        let exp = expectation(description: "loaded")
        observeState { if case .loaded = $0 { exp.fulfill() } }

        sut.load()
        await fulfillment(of: [exp], timeout: 1.0)

        guard case .loaded(let data) = sut.state else {
            return XCTFail("Expected loaded state")
        }

        XCTAssertEqual(data.title, "Inception")
    }

    func testLoad_failure_setsErrorState() async {
        repository.movieDetailResult = .failure(URLError(.notConnectedToInternet))

        let exp = expectation(description: "error")
        observeState { if case .error = $0 { exp.fulfill() } }

        sut.load()
        await fulfillment(of: [exp], timeout: 1.0)

        guard case .error(let message) = sut.state else {
            return XCTFail("Expected error state")
        }

        XCTAssertFalse(message.isEmpty)
    }

    func testRetry_reloadsData() async {
        repository.movieDetailResult = .failure(URLError(.notConnectedToInternet))

        let errorExp = expectation(description: "error")
        observeState { if case .error = $0 { errorExp.fulfill() } }

        sut.load()
        await fulfillment(of: [errorExp], timeout: 1.0)

        cancellables.removeAll()
        let movie = Movie.stub(title: "Recovered")
        repository.movieDetailResult = .success(movie)

        let loadedExp = expectation(description: "loaded after retry")
        observeState { if case .loaded = $0 { loadedExp.fulfill() } }

        sut.retry()
        await fulfillment(of: [loadedExp], timeout: 1.0)

        guard case .loaded(let data) = sut.state else {
            return XCTFail("Expected loaded state after retry")
        }

        XCTAssertEqual(data.title, "Recovered")
    }

    // MARK: - Year Formatting

    func testYearText_formatsCorrectly() async {
        let movie = Movie.stub(releaseDate: DateFormatter.tmdbDate.date(from: "2026-06-01"))
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertEqual(data.yearText, "2026")
    }

    func testYearText_nilDate_isEmpty() async {
        let movie = Movie.stub(releaseDate: nil)
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertEqual(data.yearText, "")
    }

    // MARK: - Score Formatting

    func testScore_calculatesPercentCorrectly() async {
        let movie = Movie.stub(voteAverage: 7.5)
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertEqual(data.scorePercent, 75)
        XCTAssertEqual(data.scoreText, "75%")
    }

    func testScore_roundsCorrectly() async {
        let movie = Movie.stub(voteAverage: 6.87)
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertEqual(data.scorePercent, 69)
        XCTAssertEqual(data.scoreText, "69%")
    }

    // MARK: - Runtime Formatting

    func testRuntime_formatsHoursAndMinutes() async {
        let movie = Movie.stub(runtime: 148)
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertEqual(data.runtimeText, "2h 28m")
    }

    func testRuntime_underOneHour_showsMinutesOnly() async {
        let movie = Movie.stub(runtime: 45)
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertEqual(data.runtimeText, "45m")
    }

    func testRuntime_nil_returnsNil() async {
        let movie = Movie.stub(runtime: nil)
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertNil(data.runtimeText)
    }

    // MARK: - Genres Formatting

    func testGenres_singleGenre() async {
        let movie = Movie.stub(genres: [Genre(id: 1, name: "Action")])
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertEqual(data.genresText, "Action")
    }

    func testGenres_twoGenres_joinsWithAnd() async {
        let movie = Movie.stub(genres: [
            Genre(id: 1, name: "Action"),
            Genre(id: 2, name: "Thriller")
        ])
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertEqual(data.genresText, "Action and Thriller")
    }

    func testGenres_threeGenres_usesCommaAndAnd() async {
        let movie = Movie.stub(genres: [
            Genre(id: 1, name: "Action"),
            Genre(id: 2, name: "Thriller"),
            Genre(id: 3, name: "Drama")
        ])
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertEqual(data.genresText, "Action, Thriller, and Drama")
    }

    func testGenres_empty_returnsEmpty() async {
        let movie = Movie.stub(genres: [])
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertEqual(data.genresText, "")
    }

    // MARK: - Trailer URL

    func testTrailerURL_withKey_buildsYouTubeURL() async {
        let movie = Movie.stub(trailerYouTubeKey: "dQw4w9WgXcQ")
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertEqual(data.trailerURL?.absoluteString, "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    }

    func testTrailerURL_withoutKey_isNil() async {
        let movie = Movie.stub(trailerYouTubeKey: nil)
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertNil(data.trailerURL)
    }

    // MARK: - Tagline

    func testTagline_passedThrough() async {
        let movie = Movie.stub(tagline: "Why so serious?")
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertEqual(data.tagline, "Why so serious?")
    }

    // MARK: - Cast

    func testCast_mapsMembersCorrectly() async {
        let cast = [
            CastMember(id: 1, name: "Jon Bernthal", character: "Frank Castle", profilePath: "/jon.jpg"),
            CastMember(id: 2, name: "Deborah Ann Woll", character: "Karen Page", profilePath: nil)
        ]
        let movie = Movie.stub(cast: cast)
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertEqual(data.cast.count, 2)
        XCTAssertEqual(data.cast[0].name, "Jon Bernthal")
        XCTAssertEqual(data.cast[0].character, "Frank Castle")
        XCTAssertNotNil(data.cast[0].photoURL)
        XCTAssertEqual(data.cast[1].name, "Deborah Ann Woll")
        XCTAssertNil(data.cast[1].photoURL)
    }

    func testCast_empty_returnsEmpty() async {
        let movie = Movie.stub(cast: [])
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertTrue(data.cast.isEmpty)
    }

    // MARK: - Crew

    func testCrew_mapsMembersCorrectly() async {
        let crew = [
            CrewMember(id: 1, name: "Thomas Schnauz", job: "Director", profilePath: "/thomas.jpg"),
            CrewMember(id: 2, name: "Jim Chory", job: "Executive Producer", profilePath: nil)
        ]
        let movie = Movie.stub(crew: crew)
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertEqual(data.crew.count, 2)
        XCTAssertEqual(data.crew[0].name, "Thomas Schnauz")
        XCTAssertEqual(data.crew[0].job, "Director")
        XCTAssertNotNil(data.crew[0].photoURL)
        XCTAssertEqual(data.crew[1].name, "Jim Chory")
        XCTAssertNil(data.crew[1].photoURL)
    }

    func testCrew_empty_returnsEmpty() async {
        let movie = Movie.stub(crew: [])
        repository.movieDetailResult = .success(movie)

        let data = await loadAndGetData()

        XCTAssertTrue(data.crew.isEmpty)
    }

    // MARK: - Helpers

    private func observeState(_ handler: @escaping (MovieDetailViewState) -> Void) {
        sut.$state.dropFirst().sink { handler($0) }.store(in: &cancellables)
    }

    private func loadAndGetData(file: StaticString = #file, line: UInt = #line) async -> MovieDetailLoadedState {
        let exp = expectation(description: "loaded")
        observeState { if case .loaded = $0 { exp.fulfill() } }

        sut.load()
        await fulfillment(of: [exp], timeout: 1.0)

        guard case .loaded(let data) = sut.state else {
            XCTFail("Expected loaded state", file: file, line: line)
            return MovieDetailLoadedState(
                title: "", yearText: "", tagline: nil, overview: "",
                scorePercent: 0, scoreText: "", releaseDateText: "",
                genresText: "", runtimeText: nil, posterURL: nil,
                backdropURL: nil, trailerURL: nil, cast: [], crew: []
            )
        }
        return data
    }
}
