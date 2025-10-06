//
//  OnboardingCoordinatorView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 05/10/2025.
//

import SwiftUI

struct OnboardingCoordinatorView: View {
    @StateObject private var authState = AuthenticationState()
    
    var body: some View {
        Group {
            switch authState.currentStep {
            case .welcome:
                WelcomeView()
                    .transition(.opacity)
            case .phoneEntry:
                PhoneEntryView()
                    .transition(.slide)
            case .phoneVerification:
                OTPVerificationView()
                    .transition(.slide)
            case .success:
                SuccessView()
                    .transition(.opacity)
            case .createProfile:
                CreateProfileView()
                    .transition(.slide)
            case .completed:
                // This will be replaced with the main app view later
                ContentView()
                    .transition(.opacity)
            }
        }
        .environmentObject(authState)
        .animation(.easeInOut(duration: 0.3), value: authState.currentStep)
    }
}

#Preview {
    OnboardingCoordinatorView()
}
