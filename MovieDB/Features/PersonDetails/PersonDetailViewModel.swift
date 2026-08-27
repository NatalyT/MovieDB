//
//  PersonDetailViewModel.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 05.06.26.
//

import Combine
import Data
import Domain
import Foundation

private enum Constants {
    static let maxKnownForCount = 10
}

@MainActor
final class PersonDetailViewModel: ObservableObject {

    @Published private(set) var state: PersonDetailViewState = .loading

    private let personID: Int
    private let getPersonDetail: GetPersonDetailUseCase

    init(personID: Int, getPersonDetail: GetPersonDetailUseCase) {
        self.personID = personID
        self.getPersonDetail = getPersonDetail
    }

    // MARK: - Loading

    func load() {
        state = .loading

        Task {
            do {
                let person = try await getPersonDetail.execute(id: personID)
                state = .loaded(mapToViewData(person))
            } catch {
                state = .error(ErrorMapping.mapToAlert(error))
            }
        }
    }

    func retry() {
        load()
    }

    // MARK: - Private

    private func mapToViewData(_ person: Person) -> PersonDetailLoadedState {
        let photoURL = person.profilePath.flatMap { ImageURL.url(path: $0, size: .w500) }
        let birthdayText = person.birthday.map { formatBirthday($0) }
        let genderText = formatGender(person.gender)
        let knownFor = person.knownForMovies
            .prefix(Constants.maxKnownForCount)
            .map { mapToKnownFor($0) }

        return PersonDetailLoadedState(
            name: person.name,
            biography: person.biography,
            photoURL: photoURL,
            knownForDepartment: person.knownForDepartment,
            genderText: genderText,
            birthdayText: birthdayText,
            placeOfBirth: person.placeOfBirth,
            knownForMovies: Array(knownFor)
        )
    }

    private func mapToKnownFor(_ movie: Movie) -> PersonKnownForMovie {
        let posterURL = movie.posterPath.flatMap { ImageURL.url(path: $0, size: .w185) }
        return PersonKnownForMovie(id: movie.id, title: movie.title, posterURL: posterURL)
    }

    private func formatBirthday(_ date: Date) -> String {
        let dateText = DateFormatter.displayDate.string(from: date)
        let age = Calendar.current.dateComponents([.year], from: date, to: Date()).year ?? 0
        let yearsOld = String(localized: "person.yearsOld", defaultValue: "years old")
        return "\(dateText) (\(age) \(yearsOld))"
    }

    private func formatGender(_ gender: Gender) -> String {
        switch gender {
        case .female:
            return String(localized: "person.gender.female", defaultValue: "Female")
        case .male:
            return String(localized: "person.gender.male", defaultValue: "Male")
        case .nonBinary:
            return String(localized: "person.gender.nonBinary", defaultValue: "Non-Binary")
        case .unknown:
            return "-"
        }
    }
}
