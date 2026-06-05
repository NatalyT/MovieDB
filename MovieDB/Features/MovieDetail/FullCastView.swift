//
//  FullCastView.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 05.06.26.
//

import SwiftUI

private enum Constants {
    static let photoSize: CGFloat = 80
    static let cornerRadius: CGFloat = 8
}

struct FullCastView: View {

    let cast: [CastViewData]
    let crew: [CrewViewData]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // MARK: - Cast
                sectionHeader(title: "movie.cast", count: cast.count)

                ForEach(cast) { member in
                    HStack(spacing: 16) {
                        profilePhoto(url: member.photoURL)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(member.name)
                                .font(.headline)
                            Text(member.character)
                                .font(.subheadline)
                        }
                    }
                }

                // MARK: - Crew
                if !crew.isEmpty {
                    Divider()
                        .padding(.vertical, 8)

                    sectionHeader(title: "movie.crew", count: crew.count)

                    ForEach(crew) { member in
                        HStack(spacing: 16) {
                            profilePhoto(url: member.photoURL)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(member.name)
                                    .font(.headline)
                                Text(member.job)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private func sectionHeader(title: LocalizedStringKey, count: Int) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            Text("\(count)")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 4)
    }

    private func profilePhoto(url: URL?) -> some View {
        Color.clear
            .frame(width: Constants.photoSize, height: Constants.photoSize)
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
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
    }
}
