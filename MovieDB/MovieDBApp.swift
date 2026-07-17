//
//  MovieDBApp.swift
//  MovieDB
//
//  Created by Natalia Tatarinteva on 01.06.26.
//

import SwiftUI

@main
struct MovieDBApp: App {

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        UINavigationBar.appearance().tintColor = .label
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    @StateObject private var factory = ViewModelFactory.create()

    var body: some Scene {
        WindowGroup {
            MovieListView(viewModel: factory.makeMovieListViewModel())
                .environmentObject(factory)
                .tint(.primary)
        }
    }
}
