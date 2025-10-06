//
//  AuthenticationState.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 05/10/2025.
//

import Foundation
import Combine
import Supabase

enum OnboardingStep {
    case welcome
    case phoneEntry
    case phoneVerification
    case success
    case createProfile
    case completed
}

class AuthenticationState: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var phoneNumber: String = ""
    @Published var verificationCode: String = ""
    @Published var fullName: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
    private let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
    private lazy var supabase = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    
    func moveToNextStep() {
        switch currentStep {
        case .welcome:
            currentStep = .phoneEntry
        case .phoneEntry:
            currentStep = .phoneVerification
        case .phoneVerification:
            currentStep = .success
        case .success:
            currentStep = .createProfile
        case .createProfile:
            currentStep = .completed
            isAuthenticated = true
        case .completed:
            break
        }
    }
    
    func moveToPreviousStep() {
        switch currentStep {
        case .welcome:
            break
        case .phoneEntry:
            currentStep = .welcome
        case .phoneVerification:
            currentStep = .phoneEntry
        case .success:
            currentStep = .phoneVerification
        case .createProfile:
            currentStep = .success
        case .completed:
            break
        }
    }
    
    // MARK: - Profile Management
    
    @MainActor
    func saveUserProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Create user attributes with the full name
            let attributes = UserAttributes(
                data: ["full_name": .string(fullName)]
            )
            
            // Update the user profile in Supabase
            try await supabase.auth.update(user: attributes)
            
            print("✅ User profile saved successfully.")
            
            // Move to the next step (completed)
            isLoading = false
            moveToNextStep()
            
        } catch {
            isLoading = false
            errorMessage = "Failed to save profile. Please try again."
            print("❌ Error saving user profile: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Phone Authentication
    
    @MainActor
    func sendOTP() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.auth.signInWithOTP(phone: phoneNumber)
            isLoading = false
            moveToNextStep()
            print("✅ OTP sent successfully to \(phoneNumber)")
        } catch {
            isLoading = false
            errorMessage = "Failed to send OTP. Please check your phone number."
            print("❌ Error sending OTP: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func verifyOTP() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.auth.verifyOTP(
                phone: phoneNumber,
                token: verificationCode,
                type: .sms
            )
            isLoading = false
            moveToNextStep()
            print("✅ OTP verified successfully")
        } catch {
            isLoading = false
            errorMessage = "Invalid verification code. Please try again."
            print("❌ Error verifying OTP: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sign Out
    
    @MainActor
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            isAuthenticated = false
            currentStep = .welcome
            phoneNumber = ""
            verificationCode = ""
            fullName = ""
            print("✅ User signed out successfully")
        } catch {
            print("❌ Error signing out: \(error.localizedDescription)")
        }
    }
}
