//
//  MovieProjectSwiftUIApp.swift
//  MovieProjectSwiftUI
//
//  Created by Çağatay Eğilmez on 2.01.2026.
//

import SwiftUI

@main
struct MovieProjectSwiftUIApp: App {
    private let coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            AppCoordinatorRootView(coordinator: coordinator)
        }
    }
}
