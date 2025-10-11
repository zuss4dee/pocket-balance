//
//  EmailSignInView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 07/10/2025.
//

import SwiftUI

struct EmailSignInView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authState: AuthenticationState
    @State private var email: String = ""
    @State private var password: String = ""
    
    private var isValidEmail: Bool {
        email.contains("@") && email.contains(".") && email.count > 5
    }
    
    private var isValidPassword: Bool {
        password.count >= 6
    }
    
    private var canSubmit: Bool {
        isValidEmail && isValidPassword
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 8) {
                        Text("Welcome Back")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Sign in to your account")
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
                        
                        SecureField("Enter your password", text: $password)
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
                }
                .padding(.horizontal, 20)
                
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
                
                // Sign In Button
                Button(action: {
                    Task {
                        print("🔄 Starting email sign-in process...")
                        await authState.signInWithEmail(email: email, password: password)
                        print("📧 Sign-in completed. Error message: \(authState.errorMessage ?? "nil")")
                        
                        if authState.errorMessage == nil {
                            print("✅ Sign-in successful, dismissing")
                            dismiss()
                        } else {
                            print("❌ Sign-in failed, staying on screen to show error")
                        }
                    }
                }) {
                    HStack {
                        Text("Sign In")
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
                    .background(canSubmit ? Color.blue : Color.gray.opacity(0.3))
                    .cornerRadius(28)
                }
                .disabled(!canSubmit || authState.isLoading)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Sign In")
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

#Preview {
    EmailSignInView()
        .environmentObject(AuthenticationState())
}
