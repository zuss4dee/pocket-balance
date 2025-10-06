//
//  PhoneEntryView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 05/10/2025.
//

import SwiftUI

struct PhoneEntryView: View {
    @EnvironmentObject var authState: AuthenticationState
    @State private var phoneNumber: String = ""
    
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
                .frame(height: 40)
            
            // Title
            Text("Enter mobile number")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 32)
            
            Spacer()
                .frame(height: 16)
            
            // Subtitle
            Text("Enter a mobile number below to keep your money extra safe.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
                .padding(.horizontal, 32)
            
            Spacer()
                .frame(height: 32)
            
            // Phone number input
            TextField("", text: $phoneNumber)
                .font(.system(size: 18))
                .keyboardType(.phonePad)
                .padding()
                .frame(height: 56)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 32)
            
            Spacer()
            
            // Error message
            if let errorMessage = authState.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }
            
            // Next button
            Button(action: {
                Task {
                    await authState.sendOTP()
                }
            }) {
                HStack {
                    Text("Next")
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
                    .background(phoneNumber.count >= 10 ? Color(red: 0.2, green: 0.25, blue: 0.3) : Color.gray.opacity(0.3))
                    .cornerRadius(28)
            }
            .disabled(phoneNumber.count < 10 || authState.isLoading)
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .background(Color.white)
    }
}

#Preview {
    PhoneEntryView()
        .environmentObject(AuthenticationState())
}
