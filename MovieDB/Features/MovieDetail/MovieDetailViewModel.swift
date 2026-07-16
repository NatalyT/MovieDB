//
//  MovieDetailViewModel.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 02.06.26.
//

import Foundation
import Combine

private enum Constants {
    static let youTubeWatchBaseURL = "https://www.youtube.com/watch?v="
}

@MainActor
final class MovieDetailViewModel: ObservableObject {

    @Published private(set) var state: MovieDetailViewState = .loading

    private let movieID: Int
    private let getMovieDetail: GetMovieDetailUseCase
    private let repository: MoviesRepository

    init(movieID: Int, getMovieDetail: GetMovieDetailUseCase, repository: MoviesRepository) {
        self.movieID = movieID
        self.getMovieDetail = getMovieDetail
        self.repository = repository
    }

    // MARK: - Loading

    func load() {
        state = .loading

        Task {
            do {
                let movie = try await getMovieDetail.execute(id: movieID)
                state = .loaded(mapToViewData(movie))
            } catch {
                state = .error(ErrorMapping.mapToAlert(error))
            }
        }
    }

    func retry() {
        load()
    }

    // MARK: - Private

    private func mapToViewData(_ movie: Movie) -> MovieDetailLoadedState {
        let dateText = DateFormatter.displayString(from: movie.releaseDate)
        let yearText = movie.releaseDate.map { formatYear($0) } ?? ""
        let scorePercent = Int(round(movie.voteAverage * 10))
        let scoreText = "\(scorePercent)%"
        let runtimeText = movie.runtime.map { formatRuntime($0) }
        let genresText = formatGenres(movie.genres.map(\.name))
        let posterURL = movie.posterPath.flatMap { ImageURL.url(path: $0, size: .w500) }
        let backdropURL = movie.backdropPath.flatMap { ImageURL.url(path: $0, size: .w500) }

        return MovieDetailLoadedState(
            title: movie.title,
            yearText: yearText,
            tagline: movie.tagline,
            overview: movie.overview,
            scorePercent: scorePercent,
            scoreText: scoreText,
            releaseDateText: dateText,
            genresText: genresText,
            runtimeText: runtimeText,
            posterURL: posterURL,
            backdropURL: backdropURL,
            trailerURL: movie.trailerYouTubeKey.flatMap {
                URL(string: Constants.youTubeWatchBaseURL + $0)
            },
            cast: movie.cast.map { mapToCastViewData($0) },
            crew: movie.crew.map { mapToCrewViewData($0) }
        )
    }

    private func mapToCastViewData(_ member: CastMember) -> CastViewData {
        let photoURL = member.profilePath.flatMap { ImageURL.url(path: $0, size: .w185) }
        return CastViewData(id: member.id, name: member.name, character: member.character, photoURL: photoURL)
    }

    private func mapToCrewViewData(_ member: CrewMember) -> CrewViewData {
        let photoURL = member.profilePath.flatMap { ImageURL.url(path: $0, size: .w185) }
        return CrewViewData(id: member.id, name: member.name, job: member.job, photoURL: photoURL)
    }

    private func formatYear(_ date: Date) -> String {
        let calendar = Calendar.current
        return String(calendar.component(.year, from: date))
    }

    private func formatGenres(_ names: [String]) -> String {
        switch names.count {
        case 0:
            return ""
        case 1:
            return names[0]
        case 2:
            let and = String(localized: "genres.and", defaultValue: "and")
            return "\(names[0]) \(and) \(names[1])"
        default:
            let and = String(localized: "genres.and", defaultValue: "and")
            let allButLast = names.dropLast().joined(separator: ", ")
            let last = names.last ?? ""
            return "\(allButLast), \(and) \(last)"
        }
    }

    private func formatRuntime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }

    func makePersonDetailViewModel(for personID: Int) -> PersonDetailViewModel {
        PersonDetailViewModel(personID: personID, getPersonDetail: DefaultGetPersonDetailUseCase(repository: repository), repository: repository)
    }
}
