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
    
    private let supabaseURL = URL(string: "https://dzxagbbkdzuqmcevqgwh.supabase.co")!
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6eGFnYmJrZHp1cW1jZXZxZ3doIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4MTM1MjcsImV4cCI6MjA3NTM4OTUyN30.X9lPaChueB7xSTreWiDS9IuuJIUwpagVt7AW1VWkRkg"
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
        
        // Validate phone number format
        guard !phoneNumber.isEmpty else {
            isLoading = false
            errorMessage = "Please enter a phone number."
            return
        }
        
        guard phoneNumber.hasPrefix("+") else {
            isLoading = false
            errorMessage = "Phone number must start with country code (e.g., +44)"
            return
        }
        
        do {
            print("📱 Sending OTP to: \(phoneNumber)")
            try await supabase.auth.signInWithOTP(phone: phoneNumber)
            isLoading = false
            moveToNextStep()
            print("✅ OTP sent successfully to \(phoneNumber)")
        } catch let error as NSError {
            isLoading = false
            
            // Provide more specific error messages
            if error.localizedDescription.contains("Phone provider") {
                errorMessage = "SMS service not configured. Please contact support."
            } else if error.localizedDescription.contains("Invalid") {
                errorMessage = "Invalid phone number format. Use: +[country code][number]"
            } else if error.localizedDescription.contains("rate limit") {
                errorMessage = "Too many attempts. Please try again later."
            } else {
                errorMessage = "Failed to send OTP: \(error.localizedDescription)"
            }
            
            print("❌ Error sending OTP: \(error)")
            print("❌ Error domain: \(error.domain)")
            print("❌ Error code: \(error.code)")
        }
    }
    
    @MainActor
    func verifyOTP() async {
        isLoading = true
        errorMessage = nil
        
        // Validate verification code
        guard !verificationCode.isEmpty else {
            isLoading = false
            errorMessage = "Please enter the verification code."
            return
        }
        
        guard verificationCode.count == 6 else {
            isLoading = false
            errorMessage = "Verification code must be 6 digits."
            return
        }
        
        do {
            print("🔐 Verifying OTP for: \(phoneNumber)")
            try await supabase.auth.verifyOTP(
                phone: phoneNumber,
                token: verificationCode,
                type: .sms
            )
            isLoading = false
            moveToNextStep()
            print("✅ OTP verified successfully")
        } catch let error as NSError {
            isLoading = false
            
            // Provide more specific error messages
            if error.localizedDescription.contains("Invalid") || error.localizedDescription.contains("invalid") {
                errorMessage = "Invalid verification code. Please check and try again."
            } else if error.localizedDescription.contains("expired") {
                errorMessage = "Code expired. Please request a new code."
            } else if error.localizedDescription.contains("too many") {
                errorMessage = "Too many attempts. Please try again later."
            } else {
                errorMessage = "Verification failed: \(error.localizedDescription)"
            }
            
            print("❌ Error verifying OTP: \(error)")
            print("❌ Error domain: \(error.domain)")
            print("❌ Error code: \(error.code)")
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
