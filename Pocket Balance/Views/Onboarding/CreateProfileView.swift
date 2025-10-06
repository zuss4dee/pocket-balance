//
//  CreateProfileView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 05/10/2025.
//

import SwiftUI

struct CreateProfileView: View {
    @EnvironmentObject var authState: AuthenticationState
    @State private var fullName: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Back button
            Button(action: {
                authState.moveToPreviousStep()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
            }
            .padding(.leading, 24)
            .padding(.top, 16)
            
            Spacer()
                .frame(height: 60)
            
            // Mascot
            ZStack {
                // Shadow
                Ellipse()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 160, height: 35)
                    .offset(y: 85)
                
                // Main circle
                Circle()
                    .fill(Color.black)
                    .frame(width: 180, height: 180)
                    .overlay(
                        HStack(spacing: 18) {
                            // Left eye
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 45, height: 45)
                                
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 14, height: 14)
                                    .offset(x: -5, y: -5)
                            }
                            
                            // Right eye
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 45, height: 45)
                                
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 14, height: 14)
                                    .offset(x: -5, y: -5)
                            }
                        }
                        .offset(y: -8)
                    )
                    .overlay(
                        // Smile
                        Path { path in
                            path.move(to: CGPoint(x: 65, y: 100))
                            path.addQuadCurve(
                                to: CGPoint(x: 115, y: 100),
                                control: CGPoint(x: 90, y: 112)
                            )
                        }
                        .stroke(Color.white, lineWidth: 3)
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 40)
            
            // Headline
            Text("Welcome! What's your name?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 32)
            
            Spacer()
                .frame(height: 12)
            
            // Sub-headline
            Text("This helps personalize your experience.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
                .padding(.horizontal, 32)
            
            Spacer()
                .frame(height: 32)
            
            // Name input field
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                TextField("Enter your full name", text: $fullName)
                    .font(.system(size: 18))
                    .textContentType(.name)
                    .autocapitalization(.words)
                    .padding()
                    .frame(height: 56)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isTextFieldFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1.5)
                    )
                    .focused($isTextFieldFocused)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Finish Setup button
            Button(action: {
                authState.fullName = fullName
                Task {
                    await authState.saveUserProfile()
                }
            }) {
                HStack {
                    Text("Finish Setup")
                        .font(.system(size: 18, weight: .semibold))
                    
                    if authState.isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding(.leading, 8)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(fullName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 ? Color(red: 0.2, green: 0.25, blue: 0.3) : Color.gray.opacity(0.3))
                .cornerRadius(28)
            }
            .disabled(fullName.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 || authState.isLoading)
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .background(Color.white)
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}

#Preview {
    CreateProfileView()
        .environmentObject(AuthenticationState())
}
