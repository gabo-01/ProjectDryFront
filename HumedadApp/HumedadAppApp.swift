//
//  HumedadAppApp.swift
//  HumedadApp
//
//  Created by Fernando Gabriel Martinez on 09/05/25.
//

import SwiftUI

@main
struct HumedadAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
