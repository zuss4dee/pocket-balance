//
//  AppRootView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 07/10/2025.
//

import SwiftUI
import Supabase

struct AppRootView: View {
    @State private var isCheckingAuth = true
    @State private var isAuthenticated = false
    
    var body: some View {
        Group {
            if isCheckingAuth {
                // Show a simple loading screen while checking auth
                ZStack {
                    Color(UIColor.systemBackground)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Loading...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            } else if isAuthenticated {
                // User is logged in → Show main app
                ContentView()
                    .transition(.opacity)
            } else {
                // User is NOT logged in → Show login screen
                LoginView()
                    .transition(.opacity)
                    .environmentObject(AuthenticationState())
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: isCheckingAuth)
        .task {
            await checkAuthentication()
            
            // Listen for auth state changes
            setupAuthListener()
        }
    }
    
    @MainActor
    private func checkAuthentication() async {
        // Check if there's an active Supabase session
        do {
            let session = try await SupabaseService.shared.client.auth.session
            
            // If we got a session without error, user is authenticated
            isAuthenticated = true
            print("✅ User is authenticated: \(session.user.id)")
        } catch {
            // No session or session expired → User needs to log in
            isAuthenticated = false
            print("ℹ️ No active session, showing onboarding")
        }
        
        // Done checking
        isCheckingAuth = false
    }
    
    @MainActor
    private func recheckAuthentication() async {
        // Re-check authentication without showing loading screen
        do {
            let session = try await SupabaseService.shared.client.auth.session
            isAuthenticated = true
            print("✅ Authentication refreshed: \(session.user.id)")
        } catch {
            isAuthenticated = false
            print("ℹ️ No session found")
        }
    }
    
    private func setupAuthListener() {
        // Listen for authentication state changes from Supabase
        Task {
            for await state in SupabaseService.shared.client.auth.authStateChanges {
                await MainActor.run {
                    switch state.event {
                    case .signedIn:
                        print("✅ User signed in")
                        isAuthenticated = true
                        isCheckingAuth = false
                    case .signedOut:
                        print("ℹ️ User signed out")
                        isAuthenticated = false
                    default:
                        break
                    }
                }
            }
        }
    }
}

#Preview {
    AppRootView()
}

