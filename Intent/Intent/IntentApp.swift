//
//  IntentApp.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/3/23.
//

import SwiftUI
import Firebase

@main
struct IntentApp: App {
    init () {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
