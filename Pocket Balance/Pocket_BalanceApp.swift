//
//  Pocket_BalanceApp.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 05/10/2025.
//

import SwiftUI
import GoogleSignIn

@main
struct Pocket_BalanceApp: App {
    @State private var showLaunchScreen = true
    @AppStorage("appearance") private var appearance: String = "system"
    
    init() {
        // Configure Google Sign-In
        let clientId = AppConfig.googleClientID
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Show AppRootView which handles authentication routing
                AppRootView()
                    .preferredColorScheme(selectedColorScheme)
                
                if showLaunchScreen {
                    LaunchScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                // Animate launch screen away after 3 seconds (allows animations to complete)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showLaunchScreen = false
                    }
                }
            }
        }
    }
}

private extension Pocket_BalanceApp {
    var selectedColorScheme: ColorScheme? {
        switch appearance {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil // system
        }
    }
}
