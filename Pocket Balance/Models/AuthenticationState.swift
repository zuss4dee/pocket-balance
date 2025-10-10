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
    
    // Use the shared Supabase client so AppRootView's auth listener receives events
    private var client: SupabaseClient { SupabaseService.shared.client }
    
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
            try await client.auth.update(user: attributes)
            
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
            try await client.auth.signInWithOTP(phone: phoneNumber)
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
            try await client.auth.verifyOTP(
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
    
    // MARK: - Email Authentication
    
    @MainActor
    func signInWithEmail(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("📧 Signing in with email: \(email)")
            try await client.auth.signIn(email: email, password: password)
            isLoading = false
            isAuthenticated = true
            currentStep = .completed
            print("✅ Email sign-in successful")
        } catch {
            isLoading = false
            errorMessage = "Invalid email or password. Please try again."
            print("❌ Error signing in with email: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func signUpWithEmail(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // Validate input
        guard !email.isEmpty && email.contains("@") else {
            isLoading = false
            errorMessage = "Please enter a valid email address."
            return
        }
        
        guard password.count >= 6 else {
            isLoading = false
            errorMessage = "Password must be at least 6 characters long."
            return
        }
        
        do {
            print("📧 Signing up with email: \(email)")
            let response = try await client.auth.signUp(email: email, password: password)
            isLoading = false
            
            // Check if email confirmation is required
            if response.user.emailConfirmedAt == nil {
                errorMessage = "✅ Account created! Please check your email and click the confirmation link to complete signup. If you don't see the email, check your spam folder."
                print("📧 Email confirmation required")
            } else {
                // Move to profile creation
                currentStep = .createProfile
                print("✅ Email sign-up successful")
            }
        } catch let error as NSError {
            isLoading = false
            
            // Provide more specific error messages
            if error.localizedDescription.contains("already registered") || error.localizedDescription.contains("already exists") {
                errorMessage = "❌ An account with this email already exists. Try signing in instead."
            } else if error.localizedDescription.contains("Invalid email") || error.localizedDescription.contains("invalid email") {
                errorMessage = "❌ Please enter a valid email address."
            } else if error.localizedDescription.contains("Password") || error.localizedDescription.contains("password") {
                errorMessage = "❌ Password must be at least 6 characters long."
            } else if error.localizedDescription.contains("network") || error.localizedDescription.contains("connection") {
                errorMessage = "❌ Network error. Please check your internet connection and try again."
            } else if error.localizedDescription.contains("rate limit") || error.localizedDescription.contains("too many") {
                errorMessage = "❌ Too many attempts. Please wait a few minutes and try again."
            } else if error.localizedDescription.contains("email") && error.localizedDescription.contains("confirm") {
                errorMessage = "❌ Email confirmation is not enabled. Please contact support to enable email verification."
            } else {
                errorMessage = "❌ Failed to create account. Please try again or contact support if the problem persists."
            }
            
            print("❌ Error signing up with email: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Google Sign-In
    
    @MainActor
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔍 Signing in with Google")
            // For now, we'll use a placeholder implementation
            // In a real app, you'd integrate with Google Sign-In SDK
            // and get the ID token to pass to Supabase
            
            // This is a placeholder - you'll need to implement actual Google Sign-In
            errorMessage = "Google Sign-In not yet implemented. Please use Email or Apple Sign-In."
            print("❌ Google Sign-In not implemented yet")
        } catch {
            errorMessage = "Google Sign-In failed. Please try again."
            print("❌ Error with Google Sign-In: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Apple Sign-In
    
    @MainActor
    func signInWithApple(token: Data?, fullName: PersonNameComponents?) async {
        isLoading = true
        errorMessage = nil
        
        guard let token = token,
              let tokenString = String(data: token, encoding: .utf8) else {
            errorMessage = "Failed to get Apple Sign-In token"
            isLoading = false
            return
        }
        
        do {
            print("🍎 Signing in with Apple")
            try await client.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: tokenString))
            
            // If we have the full name, save it
            if let fullName = fullName {
                let name = [fullName.givenName, fullName.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                
                if !name.isEmpty {
                    self.fullName = name
                    let attributes = UserAttributes(data: ["full_name": .string(name)])
                    try await client.auth.update(user: attributes)
                }
            }
            
            isLoading = false
            isAuthenticated = true
            currentStep = .completed
            print("✅ Apple Sign-In successful")
        } catch {
            isLoading = false
            errorMessage = "Apple Sign-In failed. Please try again."
            print("❌ Error with Apple Sign-In: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sign Out
    
    @MainActor
    func signOut() async {
        do {
            try await client.auth.signOut()
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
