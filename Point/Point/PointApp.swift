//
//  PointApp.swift
//  Point
//
//  Created by Simon Chervenak on 10/5/22.
//

import SwiftUI

@main
struct PointApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
