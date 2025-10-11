//
//  EmailSignUpView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 07/10/2025.
//

import SwiftUI

struct EmailSignUpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authState: AuthenticationState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    let onEmailConfirmationNeeded: (String) -> Void
    
    private var isValidEmail: Bool {
        email.contains("@") && email.contains(".") && email.count > 5
    }
    
    private var isValidPassword: Bool {
        password.count >= 6
    }
    
    private var passwordsMatch: Bool {
        password == confirmPassword
    }
    
    private var canSubmit: Bool {
        isValidEmail && isValidPassword && passwordsMatch
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.badge.plus.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Sign up to get started")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 40)
                .padding(.bottom, 40)
                
                // Form
                VStack(spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        TextField("Enter your email", text: $email)
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
                        Text("Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        SecureField("Create a password", text: $password)
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
                    
                    // Confirm Password Field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Confirm Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        SecureField("Confirm your password", text: $confirmPassword)
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
                .padding(.horizontal, 20)
                
                // Password Requirements - Explicit positioning
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password Requirements:")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        PasswordRequirementRow(
                            text: "At least 6 characters",
                            isMet: password.count >= 6
                        )
                        
                        PasswordRequirementRow(
                            text: "Contains letters and numbers",
                            isMet: password.rangeOfCharacter(from: .letters) != nil && password.rangeOfCharacter(from: .decimalDigits) != nil
                        )
                        
                        PasswordRequirementRow(
                            text: "Passwords match",
                            isMet: passwordsMatch && !password.isEmpty
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                Spacer()
                
                // Error Message
                if let errorMessage = authState.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                }
                
                // Create Account Button
                Button(action: {
                    Task {
                        print("🔄 Starting account creation process...")
                        await authState.signUpWithEmail(email: email, password: password)
                        print("📧 Sign up completed. Error message: \(authState.errorMessage ?? "nil")")
                        
                        // Check if email confirmation is needed
                        if authState.errorMessage?.contains("check your email") == true {
                            print("📧 Email confirmation needed, showing confirmation sheet")
                            onEmailConfirmationNeeded(email)
                            dismiss() // Dismiss after showing confirmation
                        } else if authState.errorMessage == nil {
                            print("✅ Account created successfully, dismissing")
                            dismiss() // Dismiss if no error
                        } else {
                            print("❌ Error occurred, staying on screen to show error")
                        }
                        // If there's an error (but not email confirmation), stay on screen to show error
                    }
                }) {
                    HStack {
                        Text("Create Account")
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
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Password Requirement Row

struct PasswordRequirementRow: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 12))
                .foregroundColor(isMet ? .green : .gray)
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(isMet ? .green : .secondary)
        }
    }
}

#Preview("EmailSignUpView") {
    EmailSignUpView(onEmailConfirmationNeeded: { _ in })
        .environmentObject(AuthenticationState())
}

#Preview("PasswordRequirementRow") {
    VStack(spacing: 8) {
        PasswordRequirementRow(text: "At least 6 characters", isMet: true)
        PasswordRequirementRow(text: "Contains letters and numbers", isMet: false)
        PasswordRequirementRow(text: "Passwords match", isMet: true)
    }
    .padding()
}
