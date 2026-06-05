//
//  MovieDetailView.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 02.06.26.
//

import SwiftUI

private enum Constants {
    static let backdropAspectRatio: CGFloat = 16 / 9
    static let posterWidth: CGFloat = 120
    static let posterAspectRatio: CGFloat = 2 / 3
    static let cornerRadius: CGFloat = 10
    static let scoreSize: CGFloat = 50
    static let scoreLineWidth: CGFloat = 4
    static let castPhotoSize: CGFloat = 100
    static let castCardWidth: CGFloat = 120
    static let castPreviewCount = 9
}

struct MovieDetailView: View {

    @StateObject private var viewModel: MovieDetailViewModel
    @State private var showTrailer = false

    init(viewModel: MovieDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("")
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
                VStack(alignment: .leading, spacing: 0) {
                    backdropImage(url: data.backdropURL)
                    posterAndTitleSection(data: data)
                    detailsSection(data: data)
                    castSection(cast: data.cast)
                }
            }
            .sheet(isPresented: $showTrailer) {
                if let trailerURL = data.trailerURL {
                    SafariView(url: trailerURL)
                        .ignoresSafeArea()
                }
            }

        case .error(let message):
            ErrorStateView(message: message) {
                viewModel.retry()
            }
        }
    }

    // MARK: - Backdrop

    private func backdropImage(url: URL?) -> some View {
        Color.clear
            .aspectRatio(Constants.backdropAspectRatio, contentMode: .fit)
            .overlay {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Color(.systemGray5)
                    }
                }
            }
            .clipped()
    }

    // MARK: - Trailer

    private var playTrailerButton: some View {
        Button {
            showTrailer = true
        } label: {
            Label("movie.playTrailer", systemImage: "play.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.black)
        }
    }

    // MARK: - Poster + Title

    private func posterAndTitleSection(data: MovieDetailLoadedState) -> some View {
        HStack(alignment: .top, spacing: 16) {
            posterImage(url: data.posterURL)

            VStack(alignment: .leading, spacing: 8) {
                titleView(title: data.title, year: data.yearText)

                Text(data.releaseDateText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                metadataLine(data: data)

                HStack(spacing: 8) {
                    scoreCircle(percent: data.scorePercent, text: data.scoreText)
                    Text("movie.userScore")
                        .font(.caption)
                        .fontWeight(.semibold)
                }

                if data.trailerURL != nil {
                    playTrailerButton
                }
            }
        }
        .padding()
    }

    private func titleView(title: String, year: String) -> some View {
        Group {
            if year.isEmpty {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
            } else {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                + Text(" (\(year))")
                    .font(.title2)
                    .fontWeight(.light)
            }
        }
    }

    private func metadataLine(data: MovieDetailLoadedState) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if !data.genresText.isEmpty {
                Text(data.genresText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let runtime = data.runtimeText {
                Text(runtime)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func posterImage(url: URL?) -> some View {
        Color.clear
            .aspectRatio(Constants.posterAspectRatio, contentMode: .fit)
            .frame(width: Constants.posterWidth)
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
                                Image(systemName: "film")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
            .shadow(radius: 4)
    }

    // MARK: - Details section

    private func detailsSection(data: MovieDetailLoadedState) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Tagline
            if let tagline = data.tagline, !tagline.isEmpty {
                Text(tagline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .italic()
            }

            // Overview
            if !data.overview.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("movie.overview")
                        .font(.headline)
                    Text(data.overview)
                        .font(.body)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }

    // MARK: - Cast

    private func castSection(cast: [CastViewData]) -> some View {
        Group {
            if !cast.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("movie.topBilledCast")
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 12) {
                            ForEach(cast.prefix(Constants.castPreviewCount)) { member in
                                castCard(member)
                            }

                            if cast.count > Constants.castPreviewCount {
                                NavigationLink {
                                    FullCastView(cast: cast)
                                } label: {
                                    viewMoreCard
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
        }
    }

    private var viewMoreCard: some View {
        VStack {
            Spacer()
            HStack(spacing: 4) {
                Text("movie.viewMore")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Image(systemName: "arrow.right")
                    .font(.subheadline)
            }
            Spacer()
        }
        .frame(width: Constants.castCardWidth, height: Constants.castPhotoSize)
    }

    private func castCard(_ member: CastViewData) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Color.clear
                .frame(width: Constants.castCardWidth, height: Constants.castPhotoSize)
                .overlay {
                    AsyncImage(url: member.photoURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Color(.systemGray5)
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                }
                        }
                    }
                }
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(member.name)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(2)

            Text(member.character)
                .font(.caption2)
                .lineLimit(2)
        }
        .frame(width: Constants.castCardWidth)
    }

    // MARK: - Score Circle

    private func scoreCircle(percent: Int, text: String) -> some View {
        let progress = Double(percent) / 100.0

        return ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: Constants.scoreLineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    scoreColor(percent: percent),
                    style: StrokeStyle(lineWidth: Constants.scoreLineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text(text)
                .font(.caption2)
                .fontWeight(.bold)
        }
        .frame(width: Constants.scoreSize, height: Constants.scoreSize)
    }

    private func scoreColor(percent: Int) -> Color {
        switch percent {
        case 70...:
            return .green
        case 40...:
            return .yellow
        default:
            return .red
        }
    }
}
