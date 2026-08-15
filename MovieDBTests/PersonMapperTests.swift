//
//  PersonMapperTests.swift
//  MovieDBTests
//
//  Created by Natalia Tatarinteva on 15.07.26.
//

import XCTest
@testable import Domain
@testable import MovieDB

final class PersonMapperTests: XCTestCase {

    // MARK: - Basic Mapping

    func testMap_mapsAllFields() {
        let dto = makePersonDTO(
            name: "Jon Bernthal",
            biography: "An American actor.",
            profilePath: "/jon.jpg",
            birthday: "1976-09-20",
            placeOfBirth: "Washington, D.C., USA",
            gender: 2,
            knownForDepartment: "Acting"
        )

        let person = PersonMapper.map(dto)

        XCTAssertEqual(person.name, "Jon Bernthal")
        XCTAssertEqual(person.biography, "An American actor.")
        XCTAssertEqual(person.profilePath, "/jon.jpg")
        XCTAssertNotNil(person.birthday)
        XCTAssertEqual(person.placeOfBirth, "Washington, D.C., USA")
        XCTAssertEqual(person.gender, .male)
        XCTAssertEqual(person.knownForDepartment, "Acting")
    }

    // MARK: - Gender Mapping

    func testMap_genderFemale() {
        let dto = makePersonDTO(gender: 1)
        XCTAssertEqual(PersonMapper.map(dto).gender, .female)
    }

    func testMap_genderMale() {
        let dto = makePersonDTO(gender: 2)
        XCTAssertEqual(PersonMapper.map(dto).gender, .male)
    }

    func testMap_genderNonBinary() {
        let dto = makePersonDTO(gender: 3)
        XCTAssertEqual(PersonMapper.map(dto).gender, .nonBinary)
    }

    func testMap_genderUnknown() {
        let dto = makePersonDTO(gender: 0)
        XCTAssertEqual(PersonMapper.map(dto).gender, .unknown)
    }

    func testMap_genderInvalid_defaultsToUnknown() {
        let dto = makePersonDTO(gender: 99)
        XCTAssertEqual(PersonMapper.map(dto).gender, .unknown)
    }

    // MARK: - Birthday

    func testMap_nilBirthday() {
        let dto = makePersonDTO(birthday: nil)
        XCTAssertNil(PersonMapper.map(dto).birthday)
    }

    func testMap_invalidBirthday() {
        let dto = makePersonDTO(birthday: "not-a-date")
        XCTAssertNil(PersonMapper.map(dto).birthday)
    }

    // MARK: - Known For Movies

    func testMap_knownForMovies_sortedByPopularity() {
        let credits = TMDbPersonMovieCreditsDTO(cast: [
            TMDbPersonCastCreditDTO(id: 1, title: "Low Pop", posterPath: nil, releaseDate: nil, voteAverage: 5.0, voteCount: 100, popularity: 1.0),
            TMDbPersonCastCreditDTO(id: 2, title: "High Pop", posterPath: nil, releaseDate: nil, voteAverage: 7.0, voteCount: 500, popularity: 20.0),
            TMDbPersonCastCreditDTO(id: 3, title: "Mid Pop", posterPath: nil, releaseDate: nil, voteAverage: 6.0, voteCount: 200, popularity: 10.0)
        ])
        let dto = makePersonDTO(movieCredits: credits)

        let person = PersonMapper.map(dto)

        XCTAssertEqual(person.knownForMovies.count, 3)
        XCTAssertEqual(person.knownForMovies[0].title, "High Pop")
        XCTAssertEqual(person.knownForMovies[1].title, "Mid Pop")
        XCTAssertEqual(person.knownForMovies[2].title, "Low Pop")
    }

    func testMap_knownForMovies_filtersZeroVotes() {
        let credits = TMDbPersonMovieCreditsDTO(cast: [
            TMDbPersonCastCreditDTO(id: 1, title: "Released", posterPath: nil, releaseDate: nil, voteAverage: 7.0, voteCount: 500, popularity: 10.0),
            TMDbPersonCastCreditDTO(id: 2, title: "Unreleased", posterPath: nil, releaseDate: nil, voteAverage: 0.0, voteCount: 0, popularity: 50.0)
        ])
        let dto = makePersonDTO(movieCredits: credits)

        let person = PersonMapper.map(dto)

        XCTAssertEqual(person.knownForMovies.count, 1)
        XCTAssertEqual(person.knownForMovies[0].title, "Released")
    }

    func testMap_noMovieCredits_returnsEmpty() {
        let dto = makePersonDTO(movieCredits: nil)

        let person = PersonMapper.map(dto)

        XCTAssertTrue(person.knownForMovies.isEmpty)
    }

    // MARK: - Helpers

    private func makePersonDTO(
        name: String = "Test Person",
        biography: String = "",
        profilePath: String? = nil,
        birthday: String? = nil,
        placeOfBirth: String? = nil,
        gender: Int = 0,
        knownForDepartment: String? = nil,
        movieCredits: TMDbPersonMovieCreditsDTO? = nil
    ) -> TMDbPersonDTO {
        TMDbPersonDTO(
            id: 1,
            name: name,
            biography: biography,
            profilePath: profilePath,
            birthday: birthday,
            placeOfBirth: placeOfBirth,
            gender: gender,
            knownForDepartment: knownForDepartment,
            movieCredits: movieCredits
        )
    }
}
