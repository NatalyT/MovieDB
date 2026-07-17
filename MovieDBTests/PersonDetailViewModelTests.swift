//
//  PersonDetailViewModelTests.swift
//  MovieDBTests
//
//  Created by Natalia Tatarinteva on 05.06.26.
//

import Combine
import XCTest
@testable import MovieDB

@MainActor
final class PersonDetailViewModelTests: XCTestCase {

    private var repository: FakeMoviesRepository!
    private var sut: PersonDetailViewModel!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        repository = FakeMoviesRepository()
        let getPersonDetail = DefaultGetPersonDetailUseCase(repository: repository)
        sut = PersonDetailViewModel(personID: 1, getPersonDetail: getPersonDetail)
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
        let person = Person.stub(name: "Jon Bernthal")
        repository.personDetailResult = .success(person)

        let exp = expectation(description: "loaded")
        observeState { if case .loaded = $0 { exp.fulfill() } }

        sut.load()
        await fulfillment(of: [exp], timeout: 1.0)

        guard case .loaded(let data) = sut.state else {
            return XCTFail("Expected loaded state")
        }

        XCTAssertEqual(data.name, "Jon Bernthal")
    }

    func testLoad_failure_setsErrorState() async {
        repository.personDetailResult = .failure(URLError(.notConnectedToInternet))

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
        repository.personDetailResult = .failure(URLError(.notConnectedToInternet))

        let errorExp = expectation(description: "error")
        observeState { if case .error = $0 { errorExp.fulfill() } }

        sut.load()
        await fulfillment(of: [errorExp], timeout: 1.0)

        cancellables.removeAll()
        let person = Person.stub(name: "Recovered")
        repository.personDetailResult = .success(person)

        let loadedExp = expectation(description: "loaded after retry")
        observeState { if case .loaded = $0 { loadedExp.fulfill() } }

        sut.retry()
        await fulfillment(of: [loadedExp], timeout: 1.0)

        guard case .loaded(let data) = sut.state else {
            return XCTFail("Expected loaded state after retry")
        }

        XCTAssertEqual(data.name, "Recovered")
    }

    // MARK: - Personal Info

    func testGender_male() async {
        let data = await loadAndGetData(person: .stub(gender: .male))
        XCTAssertEqual(data.genderText, "Male")
    }

    func testGender_female() async {
        let data = await loadAndGetData(person: .stub(gender: .female))
        XCTAssertEqual(data.genderText, "Female")
    }

    func testGender_nonBinary() async {
        let data = await loadAndGetData(person: .stub(gender: .nonBinary))
        XCTAssertEqual(data.genderText, "Non-Binary")
    }

    func testGender_unknown_returnsDash() async {
        let data = await loadAndGetData(person: .stub(gender: .unknown))
        XCTAssertEqual(data.genderText, "-")
    }

    func testBirthday_formatsWithAge() async {
        let data = await loadAndGetData(person: .stub(
            birthday: DateFormatter.tmdbDate.date(from: "1976-09-20")
        ))

        XCTAssertNotNil(data.birthdayText)
        XCTAssertTrue(data.birthdayText?.contains("1976") ?? false)
    }

    func testBirthday_nil_returnsNil() async {
        let data = await loadAndGetData(person: .stub(birthday: nil))
        XCTAssertNil(data.birthdayText)
    }

    func testPlaceOfBirth_passedThrough() async {
        let data = await loadAndGetData(person: .stub(placeOfBirth: "Washington, D.C., USA"))
        XCTAssertEqual(data.placeOfBirth, "Washington, D.C., USA")
    }

    func testPlaceOfBirth_nil() async {
        let data = await loadAndGetData(person: .stub(placeOfBirth: nil))
        XCTAssertNil(data.placeOfBirth)
    }

    func testKnownForDepartment_passedThrough() async {
        let data = await loadAndGetData(person: .stub(knownForDepartment: "Acting"))
        XCTAssertEqual(data.knownForDepartment, "Acting")
    }

    // MARK: - Biography

    func testBiography_passedThrough() async {
        let data = await loadAndGetData(person: .stub(biography: "An American actor."))
        XCTAssertEqual(data.biography, "An American actor.")
    }

    func testBiography_empty() async {
        let data = await loadAndGetData(person: .stub(biography: ""))
        XCTAssertEqual(data.biography, "")
    }

    // MARK: - Photo

    func testPhotoURL_withPath_isNotNil() async {
        let data = await loadAndGetData(person: .stub(profilePath: "/jon.jpg"))
        XCTAssertNotNil(data.photoURL)
    }

    func testPhotoURL_withoutPath_isNil() async {
        let data = await loadAndGetData(person: .stub(profilePath: nil))
        XCTAssertNil(data.photoURL)
    }

    // MARK: - Known For Movies

    func testKnownForMovies_mapsCorrectly() async {
        let movies = [
            Movie.stub(id: 1, title: "The Walking Dead", posterPath: "/twd.jpg"),
            Movie.stub(id: 2, title: "Fury", posterPath: nil)
        ]
        let data = await loadAndGetData(person: .stub(knownForMovies: movies))

        XCTAssertEqual(data.knownForMovies.count, 2)
        XCTAssertEqual(data.knownForMovies[0].title, "The Walking Dead")
        XCTAssertNotNil(data.knownForMovies[0].posterURL)
        XCTAssertEqual(data.knownForMovies[1].title, "Fury")
        XCTAssertNil(data.knownForMovies[1].posterURL)
    }

    func testKnownForMovies_empty() async {
        let data = await loadAndGetData(person: .stub(knownForMovies: []))
        XCTAssertTrue(data.knownForMovies.isEmpty)
    }

    func testKnownForMovies_limitedToTen() async {
        let movies = (1...15).map { Movie.stub(id: $0, title: "Movie \($0)") }
        let data = await loadAndGetData(person: .stub(knownForMovies: movies))

        XCTAssertEqual(data.knownForMovies.count, 10)
    }

    // MARK: - Helpers

    private func observeState(_ handler: @escaping (PersonDetailViewState) -> Void) {
        sut.$state.dropFirst().sink { handler($0) }.store(in: &cancellables)
    }

    private func loadAndGetData(
        person: Person,
        file: StaticString = #file,
        line: UInt = #line
    ) async -> PersonDetailLoadedState {
        repository.personDetailResult = .success(person)

        let exp = expectation(description: "loaded")
        observeState { if case .loaded = $0 { exp.fulfill() } }

        sut.load()
        await fulfillment(of: [exp], timeout: 1.0)

        guard case .loaded(let data) = sut.state else {
            XCTFail("Expected loaded state", file: file, line: line)
            return PersonDetailLoadedState(
                name: "", biography: "", photoURL: nil,
                knownForDepartment: nil, genderText: "",
                birthdayText: nil, placeOfBirth: nil,
                knownForMovies: []
            )
        }
        return data
    }
}
