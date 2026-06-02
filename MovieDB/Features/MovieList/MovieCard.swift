//
//  MovieCard.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import SwiftUI

private enum Constants {
    static let posterAspectRatio: CGFloat = 2 / 3
    static let cornerRadius: CGFloat = 10
}

struct MovieCard: View {

    let data: MovieCardViewData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            posterImage
            movieInfo
            Spacer(minLength: 0)
        }
    }

    // MARK: - Subviews

    private var posterImage: some View {
        Color.clear
            .aspectRatio(Constants.posterAspectRatio, contentMode: .fit)
            .overlay {
                AsyncImage(url: data.posterURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        posterPlaceholder
                    case .empty:
                        posterPlaceholder
                    @unknown default:
                        posterPlaceholder
                    }
                }
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
    }

    private var movieInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(data.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)

            Text(data.releaseDateText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var posterPlaceholder: some View {
        Color(.systemGray5)
            .overlay {
                Image(systemName: "film")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
    }
}
