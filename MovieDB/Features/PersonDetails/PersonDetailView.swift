//
//  PersonDetailView.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 05.06.26.
//

import SwiftUI

private enum Constants {
    static let photoWidth: CGFloat = 180
    static let photoAspectRatio: CGFloat = 2 / 3
    static let cornerRadius: CGFloat = 12
    static let knownForPosterWidth: CGFloat = 120
    static let knownForPosterAspectRatio: CGFloat = 2 / 3
    static let biographyLineLimit = 6
}

struct PersonDetailView: View {

    @StateObject private var viewModel: PersonDetailViewModel
    @EnvironmentObject private var factory: ViewModelFactory
    @State private var isBiographyExpanded = false

    init(viewModel: PersonDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.load()
            }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded(let data):
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection(data: data)
                    personalInfoSection(data: data)
                    biographySection(biography: data.biography)
                    knownForSection(movies: data.knownForMovies)
                }
                .padding()
            }

        case .error(let message):
            ErrorStateView(message: message) {
                viewModel.retry()
            }
        }
    }

    // MARK: - Header

    private func headerSection(data: PersonDetailLoadedState) -> some View {
        VStack(spacing: 16) {
            profilePhoto(url: data.photoURL)
            Text(data.name)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func profilePhoto(url: URL?) -> some View {
        Color.clear
            .aspectRatio(Constants.photoAspectRatio, contentMode: .fit)
            .frame(width: Constants.photoWidth)
            .overlay {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Color(.systemGray5)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
    }

    // MARK: - Personal Info

    private func personalInfoSection(data: PersonDetailLoadedState) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("person.personalInfo")
                .font(.title2)
                .fontWeight(.bold)

            if let department = data.knownForDepartment {
                infoRow(label: "person.knownFor", value: department)
            }

            infoRow(label: "person.gender", value: data.genderText)

            if let birthday = data.birthdayText {
                infoRow(label: "person.birthday", value: birthday)
            }

            if let birthplace = data.placeOfBirth {
                infoRow(label: "person.placeOfBirth", value: birthplace)
            }
        }
    }

    private func infoRow(label: LocalizedStringKey, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(value)
                .font(.subheadline)
        }
    }

    // MARK: - Biography

    private func biographySection(biography: String) -> some View {
        Group {
            if !biography.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("person.biography")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(biography)
                        .font(.body)
                        .lineLimit(isBiographyExpanded ? nil : Constants.biographyLineLimit)

                    if !isBiographyExpanded {
                        Button {
                            withAnimation {
                                isBiographyExpanded = true
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("person.readMore")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Known For

    private func knownForSection(movies: [PersonKnownForMovie]) -> some View {
        Group {
            if !movies.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("person.knownForMovies")
                        .font(.title2)
                        .fontWeight(.bold)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 12) {
                            ForEach(movies) { movie in
                                NavigationLink {
                                    MovieDetailView(
                                        viewModel: factory.makeMovieDetailViewModel(for: movie.id)
                                    )
                                } label: {
                                    knownForCard(movie)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
    }

    private func knownForCard(_ movie: PersonKnownForMovie) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Color.clear
                .aspectRatio(Constants.knownForPosterAspectRatio, contentMode: .fit)
                .frame(width: Constants.knownForPosterWidth)
                .overlay {
                    AsyncImage(url: movie.posterURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Color(.systemGray5)
                                .overlay {
                                    Image(systemName: "film")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                }
                        }
                    }
                }
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(movie.title)
                .font(.caption)
                .lineLimit(2)
        }
        .frame(width: Constants.knownForPosterWidth)
    }
}
