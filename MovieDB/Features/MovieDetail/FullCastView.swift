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
    let makePersonDetailViewModel: (Int) -> PersonDetailViewModel

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // MARK: - Cast
                sectionHeader(title: "movie.cast", count: cast.count)

                ForEach(cast) { member in
                    NavigationLink {
                        PersonDetailView(viewModel: makePersonDetailViewModel(member.id))
                    } label: {
                        personRow(name: member.name, subtitle: member.character, photoURL: member.photoURL)
                    }
                    .buttonStyle(.plain)
                }

                // MARK: - Crew
                if !crew.isEmpty {
                    Divider()
                        .padding(.vertical, 8)

                    sectionHeader(title: "movie.crew", count: crew.count)

                    ForEach(crew) { member in
                        NavigationLink {
                            PersonDetailView(viewModel: makePersonDetailViewModel(member.id))
                        } label: {
                            personRow(name: member.name, subtitle: member.job, photoURL: member.photoURL)
                        }
                        .buttonStyle(.plain)
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

    private func personRow(name: String, subtitle: String, photoURL: URL?) -> some View {
        HStack(spacing: 16) {
            profilePhoto(url: photoURL)

            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
            }
        }
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
