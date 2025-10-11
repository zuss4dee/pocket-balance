//
//  LoginView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 07/10/2025.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authState: AuthenticationState
    @State private var showPhoneLogin = false
    @State private var showEmailSignIn = false
    @State private var showEmailSignUp = false
    @State private var showEmailConfirmation = false
    @State private var confirmationEmail = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
                
                // App Logo/Mascot
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 120, height: 120)
                        .overlay(
                            HStack(spacing: 12) {
                                // Left eye
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 30, height: 30)
                                    
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 10, height: 10)
                                        .offset(x: -3, y: -3)
                                }
                                
                                // Right eye
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 30, height: 30)
                                    
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 10, height: 10)
                                        .offset(x: -3, y: -3)
                                }
                            }
                            .offset(y: -5)
                        )
                }
                .padding(.bottom, 40)
                
                // Title
                Text("Welcome Back")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                // Subtitle
                Text("Sign in to continue")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                
                Spacer()
                    .frame(height: 60)
                
                // Login Options
                VStack(spacing: 16) {
                    // Apple Sign-In
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            handleAppleSignIn(result)
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 56)
                    .cornerRadius(28)
                    
                    // Phone Number Login
                    Button(action: {
                        showPhoneLogin = true
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 18))
                            Text("Continue with Phone")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue)
                        .cornerRadius(28)
                    }
                    
                    // Email - Log In
                    Button(action: {
                        showEmailSignIn = true
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .font(.system(size: 18))
                            Text("Log In with Email")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(14)
                    }

                    // Email - Create Account
                    Button(action: {
                        showEmailSignUp = true
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 18))
                            Text("Create Account")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.blue)
                        .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Terms & Privacy
                Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .sheet(isPresented: $showPhoneLogin) {
                PhoneLoginSheet()
                    .environmentObject(authState)
            }
            .sheet(isPresented: $showEmailSignIn) {
                EmailSignInView()
                    .environmentObject(authState)
            }
            .sheet(isPresented: $showEmailSignUp) {
                EmailSignUpView(onEmailConfirmationNeeded: { email in
                    confirmationEmail = email
                    showEmailConfirmation = true
                })
                .environmentObject(authState)
            }
            .sheet(isPresented: $showEmailConfirmation) {
                EmailConfirmationSheet(email: confirmationEmail)
            }
        }
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                Task {
                    await authState.signInWithApple(
                        token: appleIDCredential.identityToken,
                        fullName: appleIDCredential.fullName
                    )
                }
            }
        case .failure(let error):
            print("❌ Apple Sign-In failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Phone Login Sheet

struct PhoneLoginSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authState: AuthenticationState
    @State private var countryCode: String = "+44"
    @State private var phoneNumber: String = ""
    @State private var showOTPView = false
    
    private var isValidPhoneNumber: Bool {
        let cleaned = phoneNumber.replacingOccurrences(of: " ", with: "")
        return cleaned.count >= 10 && cleaned.count <= 15
    }
    
    private var formattedPhoneNumber: String {
        let cleaned = phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
        return "\(countryCode)\(cleaned)"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 20)
                
                Text("Enter your phone number")
                    .font(.system(size: 24, weight: .bold))
                
                // Country Code + Phone number
                HStack(spacing: 12) {
                    Menu {
                        Button("+44 (UK)") { countryCode = "+44" }
                        Button("+1 (US)") { countryCode = "+1" }
                        Button("+234 (NG)") { countryCode = "+234" }
                        Button("+91 (IN)") { countryCode = "+91" }
                    } label: {
                        HStack {
                            Text(countryCode)
                                .font(.system(size: 18))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                        }
                        .padding()
                        .frame(height: 56)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                    
                    TextField("7911 123456", text: $phoneNumber)
                        .font(.system(size: 18))
                        .keyboardType(.phonePad)
                        .padding()
                        .frame(height: 56)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                Text("Format: \(formattedPhoneNumber)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let errorMessage = authState.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 20)
                }
                
                Button(action: {
                    authState.phoneNumber = formattedPhoneNumber
                    Task {
                        await authState.sendOTP()
                        if authState.errorMessage == nil {
                            showOTPView = true
                        }
                    }
                }) {
                    HStack {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                        if authState.isLoading {
                            ProgressView()
                                .tint(.white)
                                .padding(.leading, 8)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(isValidPhoneNumber ? Color.blue : Color.gray.opacity(0.3))
                    .cornerRadius(28)
                }
                .disabled(!isValidPhoneNumber || authState.isLoading)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Phone Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showOTPView) {
                OTPLoginSheet(phoneNumber: formattedPhoneNumber)
                    .environmentObject(authState)
            }
        }
    }
}

// MARK: - OTP Login Sheet

struct OTPLoginSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authState: AuthenticationState
    let phoneNumber: String
    @State private var otpCode: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 40)
                
                Text("Enter verification code")
                    .font(.system(size: 24, weight: .bold))
                
                Text("We sent a code to \(phoneNumber)")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 20)
                
                TextField("000000", text: $otpCode)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(height: 70)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal, 60)
                    .onChange(of: otpCode) { oldValue, newValue in
                        if newValue.count > 6 {
                            otpCode = String(newValue.prefix(6))
                        }
                        authState.verificationCode = otpCode
                    }
                
                Spacer()
                
                if let errorMessage = authState.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 20)
                }
                
                Button(action: {
                    Task {
                        await authState.verifyOTP()
                        // If verification successful, dismiss all sheets
                        if authState.errorMessage == nil {
                            dismiss()
                        }
                    }
                }) {
                    HStack {
                        Text("Verify")
                            .font(.system(size: 17, weight: .semibold))
                        if authState.isLoading {
                            ProgressView()
                                .tint(.white)
                                .padding(.leading, 8)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(otpCode.count == 6 ? Color.blue : Color.gray.opacity(0.3))
                    .cornerRadius(28)
                }
                .disabled(otpCode.count != 6 || authState.isLoading)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Verification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Email Confirmation Sheet

struct EmailConfirmationSheet: View {
    let email: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Success Icon
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "envelope.badge")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(.green)
                }
                
                VStack(spacing: 16) {
                    Text("Check Your Email")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text("We've sent a confirmation link to:")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text(email)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 12) {
                    Text("Please click the link in your email to verify your account and complete the signup process.")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Text("If you don't see the email, check your spam folder.")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                Button("Got it") {
                    dismiss()
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.green)
                .cornerRadius(28)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Email Confirmation")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationState())
}