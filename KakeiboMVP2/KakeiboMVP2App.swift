//
//  KakeiboMVP2App.swift
//  KakeiboMVP2
//
//  Created by Hiroki Kashihara on 2025/05/16.
//

import SwiftUI

@main
struct KakeiboMVP2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            AddExpenseView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
