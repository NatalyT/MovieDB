//
//  MovieListView.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import SwiftUI

private enum Constants {
    static let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]
    static let gridSpacing: CGFloat = 20
}

struct MovieListView: View {

    @StateObject private var viewModel: MovieListViewModel

    init(viewModel: MovieListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(AppStrings.popular)
                .navigationDestination(for: Int.self) { movieID in
                    MovieDetailView(
                        viewModel: viewModel.makeDetailViewModel(for: movieID)
                    )
                }
        }
        .task {
            viewModel.loadInitial()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded(let loadedState):
            ScrollView {
                LazyVGrid(columns: Constants.columns, spacing: Constants.gridSpacing) {
                    ForEach(loadedState.items) { item in
                        NavigationLink(value: item.id) {
                            MovieCard(data: item)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            viewModel.loadMoreIfNeeded(currentItem: item)
                        }
                    }
                }
                .padding(.horizontal)

                if loadedState.isLoadingMore {
                    ProgressView()
                        .padding()
                }

                if let error = loadedState.loadMoreError {
                    loadMoreErrorView(message: error)
                }
            }
            .refreshable {
                viewModel.refresh()
            }

        case .empty:
            VStack(spacing: 12) {
                Image(systemName: "film")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text(AppStrings.emptyMovies)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .refreshable {
                viewModel.refresh()
            }

        case .error(let message):
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text(message)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button(AppStrings.retry) {
                    viewModel.retry()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Subviews

    private func loadMoreErrorView(message: String) -> some View {
        VStack(spacing: 8) {
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
            Button(AppStrings.retry) {
                viewModel.retryLoadMore()
            }
            .font(.caption)
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
