//
//  MovieProjectSwiftUIApp.swift
//  MovieProjectSwiftUI
//
//  Created by Çağatay Eğilmez on 2.01.2026.
//

import SwiftUI
import CoreData

@main
struct MovieProjectSwiftUIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
