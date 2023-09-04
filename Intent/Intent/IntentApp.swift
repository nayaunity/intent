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
    @StateObject private var sessionStore = SessionStore()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                switch sessionStore.isUserAuthenticated {
                case .undefined:
                    Text("Loading...")
                case .signedOut:
                    LoginView()
                case .signedIn:
                    CreateProfileView().environmentObject(sessionStore)
                }
            }
        }
    }
}

