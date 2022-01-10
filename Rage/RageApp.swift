//
//  RageApp.swift
//  Rage
//
//  Created by Henry Krieger on 10.01.22.
//

import SwiftUI

@main
struct RageApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
