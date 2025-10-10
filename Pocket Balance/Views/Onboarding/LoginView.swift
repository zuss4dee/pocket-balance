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
    @State private var showEmailLogin = false
    @State private var emailSheetIsSignUp = false
    @State private var showEmailConfirmation = false
    @State private var confirmationEmail = ""
    @State private var identifier: String = ""
    
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
                Text("Pocket Balance")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                // Subtitle
                Text("Manage your finances with ease")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                
                Spacer()
                    .frame(height: 36)

                // Unified entry field + Continue, and compact provider row
                VStack(spacing: 14) {
                    TextField("Phone or email", text: $identifier)
                        .font(.system(size: 17))
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding()
                        .frame(height: 56)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)

                    Button(action: {
                        let value = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
                        if value.contains("@") {
                            emailSheetIsSignUp = false
                            showEmailLogin = true
                        } else {
                            showPhoneLogin = true
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(28)
                    }

                    VStack(spacing: 10) {
                        Text("Sign in with")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        HStack(spacing: 20) {
                            // Apple (compact)
                            SignInWithAppleButton(
                                onRequest: { request in
                                    request.requestedScopes = [.fullName, .email]
                                },
                                onCompletion: { result in
                                    handleAppleSignIn(result)
                                }
                            )
                            .signInWithAppleButtonStyle(.black)
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())

                            // Google (compact)
                            Button(action: { Task { await authState.signInWithGoogle() } }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 56, height: 56)
                                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                    Image(systemName: "g.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.red)
                                }
                            }
                        }
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
            .sheet(isPresented: $showEmailLogin) {
                EmailLoginSheet(
                    initialIsSignUp: emailSheetIsSignUp,
                    onEmailConfirmationNeeded: { email in
                        confirmationEmail = email
                        showEmailConfirmation = true
                    }
                )
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

// MARK: - Email Login Sheet

struct EmailLoginSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authState: AuthenticationState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSignUp: Bool = false
    var initialIsSignUp: Bool = false
    
    let onEmailConfirmationNeeded: (String) -> Void
    
    private var isValidEmail: Bool {
        email.contains("@") && email.contains(".") && email.count > 5
    }
    
    private var isValidPassword: Bool {
        password.count >= 6
    }
    
    private var passwordsMatch: Bool {
        !isSignUp || password == confirmPassword
    }
    
    private var canSubmit: Bool {
        isValidEmail && isValidPassword && passwordsMatch
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 20)
                
                Text(isSignUp ? "Create Account" : "Sign In")
                    .font(.system(size: 24, weight: .bold))
                
                // Instructions for account creation
                if isSignUp {
                    VStack(spacing: 12) {
                        Text("Get started with Pocket Balance")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                                Text("Track your income and expenses")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                                Text("Set budgets and financial goals")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                                Text("Monitor your financial health")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                } else {
                    // Instructions for sign in
                    VStack(spacing: 12) {
                        Text("Welcome back!")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Sign in to access your financial dashboard and continue managing your money.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                }
                
                VStack(spacing: 16) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Email", text: $email)
                            .font(.system(size: 17))
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .frame(height: 56)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        
                        if !email.isEmpty && !isValidEmail {
                            Text("Please enter a valid email address")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 4) {
                        SecureField("Password", text: $password)
                            .font(.system(size: 17))
                            .padding()
                            .frame(height: 56)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        
                        if !password.isEmpty && !isValidPassword {
                            Text("Password must be at least 6 characters")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Confirm Password Field (only for signup)
                    if isSignUp {
                        VStack(alignment: .leading, spacing: 4) {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .font(.system(size: 17))
                                .padding()
                                .frame(height: 56)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                            
                            if !confirmPassword.isEmpty && !passwordsMatch {
                                Text("Passwords do not match")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Password requirements for signup
                if isSignUp {
                    VStack(spacing: 8) {
                        Text("Password Requirements:")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 4) {
                            HStack(spacing: 8) {
                                Image(systemName: password.count >= 6 ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(password.count >= 6 ? .green : .secondary)
                                    .font(.system(size: 12))
                                Text("At least 6 characters")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(passwordsMatch ? .green : .secondary)
                                    .font(.system(size: 12))
                                Text("Passwords must match")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                
                // Additional helpful information for sign in
                if !isSignUp {
                    VStack(spacing: 12) {
                        HStack(spacing: 16) {
                            VStack(spacing: 4) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                Text("Dashboard")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 4) {
                                Image(systemName: "creditcard")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                                Text("Cards")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 4) {
                                Image(systemName: "chart.pie")
                                    .font(.system(size: 20))
                                    .foregroundColor(.orange)
                                Text("Budget")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 4) {
                                Image(systemName: "person.circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(.purple)
                                Text("Profile")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Text("Access all your financial tools in one place")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 12)
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
                        if isSignUp {
                            await authState.signUpWithEmail(email: email, password: password)
                            // Check if email confirmation is needed
                            if authState.errorMessage?.contains("check your email") == true {
                                onEmailConfirmationNeeded(email)
                            }
                        } else {
                            await authState.signInWithEmail(email: email, password: password)
                        }
                        if authState.errorMessage == nil {
                            dismiss()
                        }
                    }
                }) {
                    HStack {
                        Text(isSignUp ? "Create Account" : "Sign In")
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
                    .background(canSubmit ? Color.green : Color.gray.opacity(0.3))
                    .cornerRadius(28)
                }
                .disabled(!canSubmit || authState.isLoading)
                .padding(.horizontal, 20)
                
                Button(action: {
                    isSignUp.toggle()
                }) {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Email")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isSignUp = initialIsSignUp
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

